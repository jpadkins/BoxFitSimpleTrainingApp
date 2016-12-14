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

    public func getNextMotion(timeout: Double) -> [Double]? {
        let time = Date()

        self.listenForEvent = true
        var previousAccel = [(Double, Double, Double)](repeating: (Double(), Double(), Double()), count: 4)
        var previousGyro = [(Double, Double, Double)](repeating: (Double(), Double(), Double()), count: 4)
        let threshold = 3.0

        while(Date().timeIntervalSince(time) < 2.0) {
            for i in 0...3 {
                previousAccel[i] = accelBuffer.array[(accelBuffer.writeIndex - i) % accelBuffer.array.count]!
                previousGyro[i] = gyroBuffer.array[(gyroBuffer.writeIndex - i) % gyroBuffer.array.count]!
            }
            let accelMag3 = fabs(previousAccel[3].0)+fabs(previousAccel[3].1)+fabs(previousAccel[3].2)
            let accelMag2 = fabs(previousAccel[2].0)+fabs(previousAccel[2].1)+fabs(previousAccel[2].2)
            let accelMag1 = fabs(previousAccel[1].0)+fabs(previousAccel[1].1)+fabs(previousAccel[1].2)
            let accelMag0 = fabs(previousAccel[0].0)+fabs(previousAccel[0].1)+fabs(previousAccel[0].2)
            
            let gyroMag3 = fabs(previousGyro[3].0)+fabs(previousGyro[3].1)+fabs(previousGyro[3].2)
            let gyroMag2 = fabs(previousGyro[2].0)+fabs(previousGyro[2].1)+fabs(previousGyro[2].2)
            let gyroMag1 = fabs(previousGyro[1].0)+fabs(previousGyro[1].1)+fabs(previousGyro[1].2)
            let gyroMag0 = fabs(previousGyro[0].0)+fabs(previousGyro[0].1)+fabs(previousGyro[0].2)

            let accelDiff1 = fabs(accelMag3 - accelMag2)
            let accelDiff2 = fabs(accelMag1 - accelMag0)
            let accelDiff3 = accelDiff2 - accelDiff1
            
            let gyroDiff1 = fabs(gyroMag3 - gyroMag2)
            let gyroDiff2 = fabs(gyroMag1 - gyroMag0)
            let gyroDiff3 = gyroDiff2 - gyroDiff1
            
            if (accelDiff3 > threshold) || (gyroDiff3 > threshold) {
                print("broke threshold")
                sleep(1)
                return getData()
            }
        }
        return nil
    }

    public func getData() -> [Double] {
        var data = [Double](repeating:Double(), count:(50*6))
        var mean_array = [Double](repeating:Double(), count:6)

        // populate data from ring buffers
        for i in 0...49 {
            let accelIndex = (self.accelBuffer.writeIndex - i) % 50
            data[(i*6)+0] = (self.accelBuffer.array[accelIndex]?.0)!
            data[(i*6)+1] = (self.accelBuffer.array[accelIndex]?.1)!
            data[(i*6)+2] = (self.accelBuffer.array[accelIndex]?.2)!
            let gyroIndex = (self.gyroBuffer.writeIndex - i) % 50
            data[(i*6)+3] = (self.gyroBuffer.array[gyroIndex]?.0)!
            data[(i*6)+4] = (self.gyroBuffer.array[gyroIndex]?.1)!
            data[(i*6)+5] = (self.gyroBuffer.array[gyroIndex]?.2)!
            for j in 0...5 {
                mean_array[j] += data[(i*6)+j]
            }
        }

        // process data by averaging with a sliding window
        for i in 1...48 {
            for j in 0...5 {
                data[(i*6)+j] = data[((i*6)+j)-1] + data[(i*6)+j] + data[((i*6)+j)+1] / 3.0
            }
        }

        // create mean array
        for i in 0...5 {
            mean_array[i] /= 50
        }

        // create standard dev mean array
        var standard_dev_mean_array = [Double](repeating:Double(), count:6)
        for i in 0...49 {
            for j in 0...5 {
                standard_dev_mean_array[j] += mean_array[j] - data[(i*6)+j]
            }
        }
        for i in 0...5 {
            standard_dev_mean_array[i] /= 50
        }

        data += mean_array
        data += standard_dev_mean_array
        
        return data
    }
}

