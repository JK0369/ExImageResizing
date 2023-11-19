//
//  ViewController.swift
//  ExImageResizing
//
//  Created by 김종권 on 2023/11/19.
//

import UIKit

class ViewController: UIViewController {
    private let tableView = {
        let view = UITableView()
        view.allowsSelection = false
        view.backgroundColor = .clear
        view.separatorStyle = .none
        view.contentInset = .zero
        view.register(MyTableViewCell.self, forCellReuseIdentifier: MyTableViewCell.id)
        view.estimatedRowHeight = 34
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var dataSource = [MyModel]()
    var testRange = (1...1)
    let image = UIImage(named: "img")!
    var imageSize: CGSize {
        image.size
    }
    var smallSize: CGSize {
        CGSize(width: imageSize.width / 10, height: imageSize.height / 10)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
        
        tableView.dataSource = self
        
        let normalItem = MyModel(text: "normal item:", image: image)
        dataSource.append(normalItem)
        
//        benchmarkNormal()
//        benchmarkResizeV1()
//        benchmarkResizeV2()
        
        print(image.imageOrientation == .up) // false
        print(image.resizeV3(to: .init(width: 100, height: 100))?.imageOrientation == .up) // true
        benchmarkResizeV3()
        
//        tableView.reloadData()
    }
    
    func benchmarkNormal() {
        testRange
            .forEach { idx in
                let item = MyModel(text: "normal item \(idx):", image: image)
                dataSource.append(item)
            }
    }
    
    func benchmarkResizeV1() {
        testRange
            .forEach { idx in
                let resizedItem = MyModel(text: "resized item \(idx):", image: image.resizeV1(to: smallSize))
                dataSource.append(resizedItem)
            }
    }
    
    func benchmarkResizeV2() {
        testRange
            .forEach { idx in
                let resizedItem = MyModel(text: "resized item \(idx):", image: image.resizeV2(to: smallSize))
                dataSource.append(resizedItem)
            }
    }
    
    func benchmarkResizeV3() {
        testRange
            .forEach { idx in
                print(idx)
                let resizedItem = MyModel(text: "resized item \(idx):", image: image.resizeV3(to: smallSize))
                dataSource.append(resizedItem)
            }
    }
    
    func getMemoryUsage() -> Int {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: Int32.self, capacity: 1) { (pointer: UnsafeMutablePointer<Int32>) in
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), pointer, &count)
            }
        }

        return kerr == KERN_SUCCESS ? Int(info.resident_size) / (1024 * 1024) : 0
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyTableViewCell.id, for: indexPath) as! MyTableViewCell
        cell.prepare(model: dataSource[indexPath.row])
        return cell
    }
}

extension UIImage {
    func resizeV1(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
    
    func resizeV2(to size: CGSize) -> UIImage {
        let render = UIGraphicsImageRenderer(size: size)
        return render.image { context in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func resizeV3(to size: CGSize) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
            kCGImageSourceCreateThumbnailWithTransform: true
        ]
        
        guard
            let data = jpegData(compressionQuality: 1.0),
            let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
            let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
        else { return nil }
        
        let resizedImage = UIImage(cgImage: cgImage)
        return resizedImage
    }
}
