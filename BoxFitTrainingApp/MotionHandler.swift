import MotionKit

//
// This code was adapted from
// https://github.com/raywenderlich/swift-algorithm-club/tree/master/Ring%20Buffer
// Thank you Matthijs Hollemans, whoever you are
//

public struct RingBuffer<T> {
    public var array: [T?]
    public var readIndex = 0
    fileprivate var writeIndex = 0

    public init(count: Int) {
        array = [T?](repeating: nil, count: count)
    }

    public mutating func write(_ element: T) -> Bool {
        if !isFull {
            array[writeIndex % array.count] = element
            writeIndex += 1
            return true
        } else {
            return false
        }
    }

    public mutating func read() -> T? {
        if !isEmpty {
            let element = array[readIndex % array.count]
            readIndex += 1
            return element
        } else {
            return nil
        }
    }

    fileprivate var availableSpaceForReading: Int {
        return writeIndex - readIndex
    }

    public var isEmpty: Bool {
        return availableSpaceForReading == 0
    }

    fileprivate var availableSpaceForWriting: Int {
        return array.count - availableSpaceForReading
    }

    public var isFull: Bool {
        return false
    }
}

class MotionHandler: NSObject {
    private let interval : Double;
    private let motionKit = MotionKit()
    public var accelBuffer = RingBuffer<(Double, Double, Double)>(count: 50)
    public var gyroBuffer = RingBuffer<(Double, Double, Double)>(count: 50)

    var listenForEvent = false
    init(i: Double) {
        self.interval = i
    }

    public func start() {
        self.motionKit.getAccelerometerValues(self.interval) {
            (x, y, z) in
            _ = self.accelBuffer.write((x, y, z))
        }
        self.motionKit.getGyroValues(self.interval) {
            (x, y, z) in
            _ = self.gyroBuffer.write((x, y, z))
        }
    }
    
    public func stop() {
        motionKit.stopAccelerometerUpdates()
        motionKit.stopGyroUpdates()
    }
    
    public func getNextMotion(timeout: Double) -> [[Double]]? {
        let time = Date()
        
        self.listenForEvent = true
        var previousAccel = [(Double, Double, Double)](repeating: (Double(), Double(), Double()), count: 4)
        var previousGyro = [(Double, Double, Double)](repeating: (Double(), Double(), Double()), count: 4)
        let threshold = 1.0
        
        
        while(Date().timeIntervalSince(time) < 1.0) {
            for i in 0...3 {
                previousAccel[i] = accelBuffer.array[(accelBuffer.writeIndex - i) % accelBuffer.array.count]!
                previousGyro[i] = gyroBuffer.array[(gyroBuffer.writeIndex - i) % gyroBuffer.array.count]!
            }
            let mag3 = fabs(previousAccel[3].0)+fabs(previousAccel[3].1)+fabs(previousAccel[3].2)
            let mag2 = fabs(previousAccel[2].0)+fabs(previousAccel[2].1)+fabs(previousAccel[2].2)
            let mag1 = fabs(previousAccel[1].0)+fabs(previousAccel[1].1)+fabs(previousAccel[1].2)
            let mag0 = fabs(previousAccel[0].0)+fabs(previousAccel[0].1)+fabs(previousAccel[0].2)
            
            let diff1 = fabs(mag3 - mag2)
            let diff2 = fabs(mag1 - mag0)
            let diff3 = diff2 - diff1
            if diff3 > threshold {
                print("broke threshold")
                sleep(1)
                return getData()
            }
        }
        return nil

    }
    
    public func getData() -> [[Double]] {
        var data = [[Double]](repeating:[Double](repeating:Double(), count:6), count:50)
        // populate data from ring buffers
        for i in 0...49 {
            let accelIndex = (self.accelBuffer.writeIndex - i) % 50
            data[i][0] = (self.accelBuffer.array[accelIndex]?.0)!
            data[i][1] = (self.accelBuffer.array[accelIndex]?.1)!
            data[i][2] = (self.accelBuffer.array[accelIndex]?.2)!
            let gyroIndex = (self.gyroBuffer.writeIndex - i) % 50
            data[i][3] = (self.gyroBuffer.array[gyroIndex]?.0)!
            data[i][4] = (self.gyroBuffer.array[gyroIndex]?.1)!
            data[i][5] = (self.gyroBuffer.array[gyroIndex]?.2)!
        }
        // process data by averaging with a sliding window
        for i in 1...48 {
            for j in 0...5 {
                data[i][j] = (data[i-1][j] + data[i][j] + data[i+1][j]) / 3.0
            }
        }
        return data
    }
}

