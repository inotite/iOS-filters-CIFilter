@objc class JPTiltShiftGenerator: NSObject, CIFilterConstructor {
    @objc func filterWithName(name: String)->CIFilter? {
        return JPTiltShift()
    }
}

class JPTiltShift : CIFilter {


    class func register() {
        let attr: [String: AnyObject] = [:]
        CIFilter.registerFilterName("JPTiltShift", constructor: JPTiltShiftGenerator(), classAttributes: attr)
    }


    var inputImage:CIImage?
    var inputRadius:CGFloat = 10
    var inputTop:CGFloat = 0.5
    var inputCenter:CGFloat = 0.25
    var inputBottom:CGFloat = 0.75

    override func setDefaults() {
        self.setValue(CGFloat(10), forKey:"inputRadius")
        self.setValue(CGFloat(0.5), forKey:"inputCenter")
        self.setValue(CGFloat(0.25), forKey:"inputBottom")
        self.setValue(CGFloat(0.75), forKey:"inputTop")
    }

    override var outputImage:CIImage? {
    let cropRect = self.inputImage!.extent
    let height = cropRect.size.height

        var blur = CIFilter(name: "CIGaussianBlur",
            withInputParameters:["inputImage" : self.inputImage!,
                                "inputRadius":self.inputRadius])


    blur = CIFilter(name: "CICrop",
        withInputParameters:["inputImage" : blur!.outputImage!,
                            "inputRectangle":CIVector(CGRect: cropRect)])

     var topGradient = CIFilter(name: "CILinearGradient",
        withInputParameters:["inputPoint0" : CIVector(x: 0, y: self.inputTop * height),
                            "inputColor0" : CIColor(red: 0, green: 1, blue: 0, alpha: 1),
                            "inputPoint1" : CIVector(x: 0, y: self.inputCenter * height),
                            "inputColor1" : CIColor(red: 0, green: 1, blue: 0, alpha: 0)
        ])


        var bottomGradient = CIFilter(name: "CILinearGradient",
            withInputParameters:["inputPoint0" : CIVector(x: 0, y: self.inputBottom * height),
                                "inputColor0" : CIColor(red: 0, green: 1, blue: 0, alpha: 1),
                                "inputPoint1" : CIVector(x: 0, y: self.inputCenter * height),
                                "inputColor1" : CIColor(red: 0, green: 1, blue: 0, alpha: 0)
            ])



        topGradient = CIFilter(name: "CICrop",
            withInputParameters:["inputImage" : topGradient!.outputImage!,
                                 "inputRectangle":CIVector(CGRect: cropRect)
            ])

        bottomGradient = CIFilter(name: "CICrop",
            withInputParameters:["inputImage" : bottomGradient!.outputImage!,
                                 "inputRectangle":CIVector(CGRect: cropRect)
            ])


    let gradients = CIFilter(name: "CIAdditionCompositing",
        withInputParameters: ["inputImage" : topGradient!.outputImage!,
                            "inputBackgroundImage" : bottomGradient!.outputImage!
        ])

        let tiltShift = CIFilter(name: "CIBlendWithMask",
            withInputParameters: ["inputImage" : blur!.outputImage!,
                                 "inputBackgroundImage" : self.inputImage!,
                                 "inputMaskImage" :gradients!.outputImage!
            ])



    return CIImage()
    }
}
