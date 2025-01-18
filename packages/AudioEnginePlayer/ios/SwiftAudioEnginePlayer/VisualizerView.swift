import UIKit

class VisualizerView: UIView {
    private var magnitudes: [Float] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black // 设置背景颜色
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .black // 设置背景颜色
    }

    func update(with magnitudes: [Float]) {
        self.magnitudes = magnitudes
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard !magnitudes.isEmpty else { return }

        let context = UIGraphicsGetCurrentContext()
        context?.clear(rect)

        let barWidth = rect.width / CGFloat(magnitudes.count)
        for (index, magnitude) in magnitudes.enumerated() {
            let barHeight = CGFloat(magnitude) * rect.height
            let barRect = CGRect(x: CGFloat(index) * barWidth, y: rect.height - barHeight, width: barWidth, height: barHeight)
            context?.setFillColor(UIColor.green.cgColor) // 设置填充颜色
            context?.fill(barRect)
        }

        // 添加调试日志
        //print("Drawing \(magnitudes.count) bars")
    }
}
