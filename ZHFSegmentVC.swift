//
//  ZHFSegmentVC.swift
//  ZHFSegment
//
//  Created by 张海峰 on 2018/11/26.
//  Copyright © 2018年 张海峰. All rights reserved.

import UIKit

class ZHFSegmentVC: BaseViewController {
    
    /******** 按钮***********/
    
    //返回按钮
    var showBackBtn:Bool = false    //是否展示返回按钮
    var backHandle : (()->())?      //按钮回调
    fileprivate lazy var backBtn:UIButton = UIButton(frame: CGRect.init(x: 10, y: navH - 45, width: 44, height: 45))
    var backBtnImg:String = ""      //返回按钮的图片
    fileprivate lazy var backImgV:UIImageView = UIImageView(frame: CGRect.init(x: 22, y: navH - 30, width: 10, height: 17))
    
    //最靠右边的barButtonItem
    var showRightBtn:Bool = false   //是否展示
    var rightBtnOneImg:String = ""  //按钮的图片
    var btnOneHandle : (()->())?    //按钮回调
    lazy var rightBtnOne:UIButton = UIButton(frame: CGRect.init(x: ScreenWidth - 40, y: navH, width: 32, height: 45))
    
    //第二个barButtonItem
    var showRightBtnTwo:Bool = false  //是否展示
    var rightBtnTwoImg:String = ""    //按钮的图片
    var btnTwoHandle : (()->())?      //按钮回调
    lazy var rightBtnTwo:UIButton = UIButton(frame: CGRect.init(x: ScreenWidth - 40 - 32, y: navH - 45, width: 32, height: 45))
    
    /******** 属性 ********/
    fileprivate var titleBgViewW = ScreenWidth //标题view的宽
    var leftAndRightMargin:CGFloat = 0.0 //标题view左右两边的距离
    var isHave_Navgation :Bool = false //是否有导航
    var isHave_Tabbar :Bool = false{didSet{refreshFrame()}} //是否有TabBar

    var btnW :CGFloat = 100      //每个按钮的宽
    var selectId : NSInteger = 0 // 选中的ID （默认第一个）
    var pointArr = [0]{didSet{refreshAngle()}}//确定右上角是否有脚标(0为没有，大于0都有)
    var pointColor:UIColor = .black //脚标颜色
    var isScroll: Bool = true       //是否可以滚动
    
    let titleViewBottomLine: UIView = UIView()           //titleView的下划线
    var lineColor = ZHFColor.zhf_strColor(hex: "F78832") //titleView的下划线的颜色
    let titleBtnBottomLine :UIView = UIView()  //titleBtn的下划线
    
    let titleScrollView :UIScrollView = UIScrollView()
    var contentYFromZero : Bool = false  //内容view的y是否从屏幕0开始
    let contentScrollView :UIScrollView = UIScrollView()
    
    var isNested:Bool = false //是否是嵌套（大页面控制器嵌套小页面控制器）
    var titleScrollViewH : CGFloat = 44       // titleView 的高度
    var titleScrollViewY : CGFloat = navH     // titleView 的y
    var titleScrollVColor : UIColor = .white  // titleView 的背景颜色
    var titleColor = MainTextColor            //title默认颜色
    var titleSelectedColor = BtnSelectRed     //title选中颜色
    var titleFont:UIFont = UIFont.systemFont(ofSize: 16.0) //titile的font
    var titleScale :CGFloat = 1.3 // title有缩放效果，选中时是没选中的1.3倍
    
    var radioBtn :UIButton = UIButton() //定义一个承接按钮，用于保证单选
    var count :NSInteger = 0            //子控制器个数
    lazy var titleBtns : NSMutableArray = NSMutableArray()
    lazy var pointViews : NSMutableArray = NSMutableArray()
    var isShowBottomLine : Bool = false //是否显示底部的分割线
    var bottomLineSpace : CGFloat = 0   // 底部的分割线 距离左右的空间
    
    var scroCurrentPage:((Int)->())? //滑动到当前页面回调
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        //返回按钮
        if showBackBtn {
            backImgV.image = UIImage.init(named: backBtnImg)
            backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
            self.view.addSubview(backImgV)
            self.view.addSubview(backBtn)
        }
        
        //最靠右边的barButtonItem
        if showRightBtn {
            rightBtnOne.setImage(UIImage.init(named: rightBtnOneImg), for: .normal)
            rightBtnOne.addTarget(self, action: #selector(btnOneAction), for: .touchUpInside)
            self.view.addSubview(rightBtnOne)
        }
        
        //第二个barButtonItem
        if showRightBtnTwo {
            rightBtnTwo.setImage(UIImage.init(named: rightBtnTwoImg), for: .normal)
            rightBtnTwo.addTarget(self, action: #selector(btnTwoAction), for: .touchUpInside)
            self.view.addSubview(rightBtnTwo)
        }

        titleScrollView.backgroundColor = self.titleScrollVColor
        self.view.addSubview(titleScrollView)
        self.view.addSubview(contentScrollView)
        self.refreshFrame()
        //设置代理。目的：监听内容滚动视图 什么时候滚动完成
        contentScrollView.delegate = self;
        //分页
        contentScrollView.isPagingEnabled = true;
        //弹簧
        contentScrollView.bounces = false;
    }

    //返回按钮的回调
    @objc fileprivate func backAction(){
        if backHandle != nil {
            backHandle!()
        }
    }
    //最靠右边的barButtonItem
    @objc fileprivate func btnOneAction(){
        if btnOneHandle != nil {
            btnOneHandle!()
        }
    }
    //第二个barButtonItem
    @objc fileprivate func btnTwoAction(){
        if btnTwoHandle != nil {
            btnTwoHandle!()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.hbd_barHidden = true
        self.hbd_barAlpha = 0.0
    }
}

//MARK:-  设置UI
extension ZHFSegmentVC:UIScrollViewDelegate{
    
    func setupAllTitle() {
        
        count = self.children.count;
        let btnH :CGFloat = self.titleScrollView.bounds.size.height
        var btnX :CGFloat = 0
        
        for i in 0 ..< count {
            
            let titleBtn :UIButton = UIButton.init(type:UIButton.ButtonType.custom)
            let VC :UIViewController = self.children[i]
            titleBtn.setTitle(VC.title, for: UIControl.State.normal)
            btnX = CGFloat(i) * btnW
            titleBtn.tag = i
            titleBtn.setTitleColor(titleColor, for: UIControl.State.normal)
            
            titleBtn.titleLabel?.font = self.titleFont
            titleBtn.frame = CGRect.init(x: btnX, y: 0, width: btnW, height: btnH)
            titleBtn.addTarget(self, action: #selector(titleBtnClick), for: .touchUpInside)
            self.titleBtns.add(titleBtn)
            if i == selectId {
                titleBtnClick(titleBtn: titleBtn)
            }
            titleScrollView.addSubview(titleBtn)
            titleScrollView.contentSize = CGSize.init(width: CGFloat(count) * btnW, height: 0)
            titleScrollView.showsHorizontalScrollIndicator = false;
            contentScrollView.contentSize = CGSize.init(width: CGFloat(count) * ScreenWidth, height: 0)
            contentScrollView.showsHorizontalScrollIndicator = false;
            if isScroll == false{
                contentScrollView.isScrollEnabled = false
            }
        }
        if isShowBottomLine {
            setTitleViewBottomLine()
        }
    }
    
    //刷新主框架frame
    func refreshFrame() {
        
        //没有导航栏
        if isHave_Navgation == false {

            var x : CGFloat = 0
            if showBackBtn { //展示 返回按钮
                x = 50
                titleBgViewW = titleBgViewW - 50
            }
            if showRightBtn { //展示 最靠右边的barButtonItem
                titleBgViewW = titleBgViewW - 40
            }
            if showRightBtn && showRightBtnTwo { //展示 第二个barButtonItem
                titleBgViewW = titleBgViewW - 40
            }
            if leftAndRightMargin > 0 {
                if x == 0 {
                    x = leftAndRightMargin
                }else{
                    x += leftAndRightMargin - x
                }
                titleBgViewW = ScreenWidth - (x * 2)
            }
            
            if isNested {
                titleScrollViewY = 0
            }else {
                titleScrollViewY = titleScrollViewY - 44 //减 44 不是减64 考虑到状态栏的高度为20
            }
            titleScrollView.frame = CGRect.init(x: x, y: titleScrollViewY, width: titleBgViewW, height: titleScrollViewH)
        }
        //有导航栏
        else{
            titleScrollView.frame = CGRect.init(x: 0, y: titleScrollViewY, width: ScreenWidth, height: titleScrollViewH)
        }
        
        let y : CGFloat = contentYFromZero ? 0 : titleScrollView.frame.maxY + 1
        //有tabbar
        if isHave_Tabbar == true {
            
//            var conH = ScreenHeight - y - 50
//            if isNested {
//                conH = ScreenHeight - y - 50 - kTabBarHeight
//            }
            contentScrollView.frame = CGRect.init(x: 0, y: y, width: ScreenWidth, height: ScreenHeight - y - kTabBarHeight)
        }
        //没有tabbar
        else{
            contentScrollView.frame = CGRect.init(x: 0, y: y, width: ScreenWidth, height: ScreenHeight - y)
        }
        titleViewBottomLine.frame = CGRect.init(x: bottomLineSpace, y: titleScrollView.frame.maxY, width: ScreenWidth - bottomLineSpace*2, height: 0.5)
        self.view.bringSubviewToFront(self.titleScrollView)
    }
    
    //设置按钮下划线
    func setTitleBtnBottomLine(){
        titleBtnBottomLine.backgroundColor = lineColor
        titleBtnBottomLine.layer.cornerRadius = 2
        titleBtnBottomLine.clipsToBounds = true
        titleScrollView.addSubview(titleBtnBottomLine)
    }
    
    //设置titleView下划线
    func setTitleViewBottomLine(){
        titleViewBottomLine.backgroundColor = UIColor.withHex(hexString: "E7E7E7")
        self.view.addSubview(titleViewBottomLine)
    }
    
    //设置角标
    func setAngle(){
        for i in 0 ..< self.titleBtns.count {
            let btn: UIButton = self.titleBtns[i] as! UIButton
           
            if pointArr.count > i{
                let isHavePoint : NSInteger = pointArr[i]
                let titleLenth: CGFloat = CGFloat((btn.titleLabel?.text?.count)! * 12)
                let pointView: UIView = UIView.init(frame: CGRect.init(x: btnW/2 + titleLenth/2 + 3  , y: titleScrollViewH/2 - 10, width: 6, height: 6))
                pointView.layer.cornerRadius = 3
                pointView.layer.masksToBounds = true
                if isHavePoint > 0{
                    pointView.backgroundColor = pointColor
                }
                else{
                    pointView.backgroundColor = ZHFColor.clear
                }
                btn.addSubview(pointView)
                self.pointViews.add(pointView)
            }
        }
    }
    
    //刷新角标
    func refreshAngle(){
        for i in 0 ..< self.pointViews.count {
            let pointView:UIView = self.pointViews[i] as! UIView
            if pointArr.count > i{
                let isHavePoint : NSInteger = pointArr[i]
                if isHavePoint > 0{
                    pointView.backgroundColor = pointColor
                }
                else{
                    pointView.backgroundColor = ZHFColor.clear
                }
                self.pointViews.replaceObject(at: i, with: pointView)
            }
        }
    }
}

//MARK:-  处理关联事件
extension ZHFSegmentVC{
    
    @objc func titleBtnClick(titleBtn: UIButton)  {
        setupOneViewController(btnTag :titleBtn.tag)
        selButton(btn: titleBtn)
        let x :CGFloat  = CGFloat(titleBtn.tag) * ScreenWidth;
        self.contentScrollView.contentOffset = CGPoint.init(x: x, y: 0);
        selectId = radioBtn.tag
    }
    
    func selButton(btn: UIButton){
        radioBtn.transform = CGAffineTransform(scaleX: 1, y: 1);
        radioBtn.setTitleColor(titleColor, for: UIControl.State.normal)
        btn.transform = CGAffineTransform(scaleX: titleScale, y: titleScale);
        btn.setTitleColor(titleSelectedColor, for: UIControl.State.normal)
        
        radioBtn = btn
        selectId = btn.tag
        //移动线
        let x1 :CGFloat = radioBtn.center.x - btnW/3
        titleBtnBottomLine.frame = CGRect.init(x: x1, y: titleScrollViewH - 3, width: btnW*2/3, height: 3)
    }
    
    @objc func  setupOneViewController(btnTag: NSInteger){
        if btnTag < count{
            let VC : UIViewController = self.children[btnTag]
            if (VC.view.superview != nil) {
                return
            }
            let x : CGFloat = CGFloat(btnTag) * ScreenWidth
            VC.view.frame = CGRect.init(x: x, y: 0, width: ScreenWidth, height: contentScrollView.bounds.size.height)
            self.contentScrollView.addSubview(VC.view)
        }
    }
    
    @objc func setupTitleCenter(btn: UIButton){
        
        var offsetPoint : CGPoint = titleScrollView.contentOffset
        offsetPoint.x =  btn.center.x -  titleBgViewW / 2
        
        //左边超出处理
        if offsetPoint.x < 0{
            offsetPoint.x = 0
        }
        
        //右边超出处理
        let maxX : CGFloat = titleScrollView.contentSize.width - titleBgViewW;
        if maxX > 0 {
            if offsetPoint.x > maxX {
                offsetPoint.x = maxX
            }
        }else{
            offsetPoint.x = 0
        }
        
        titleScrollView.setContentOffset(offsetPoint, animated: true)
        radioBtn = btn;
    }
}

//MARK:-  处理UIScrollViewDelegate事件
extension ZHFSegmentVC {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.contentScrollView {
            //当前展示页面
            let leftI :NSInteger = NSInteger(scrollView.contentOffset.x / ScreenWidth);
            
            let currentPage:Float = Float(scrollView.contentOffset.x / ScreenWidth)
            let temNum:Float = roundf(currentPage)
            if currentPage == temNum {
                if scroCurrentPage != nil {
                    scroCurrentPage!(Int(currentPage))
                }
            }
            
            //获取标题
            let rightI :NSInteger = leftI + 1
            //选中标题
            if (rightI <= titleBtns.count) {
                let titleBtn :UIButton  = titleBtns[leftI] as! UIButton
                setupOneViewController(btnTag: rightI)
                //显示选中控制器的同时也把旁边的也加载出来
                setupOneViewController(btnTag: titleBtn.tag)
                selButton(btn: titleBtn)
                setupTitleCenter(btn: titleBtn)
            }
            //字体缩放 1.缩放比例 2.缩放那两个按钮
            //获取左边的按钮
            let leftBtn :UIButton  = self.titleBtns[leftI] as! UIButton
            //获取右边的按钮
            var rightBtn :UIButton = UIButton()
            if (rightI<self.titleBtns.count) {
                rightBtn  = self.titleBtns[rightI] as! UIButton
            }
            var scaleR :CGFloat  = scrollView.contentOffset.x / ScreenWidth;
            scaleR -=  CGFloat(leftI)
            let scaleL :CGFloat  = 1 - scaleR;
            //缩放按钮
            leftBtn.transform = CGAffineTransform.init(scaleX: scaleL * CGFloat(titleScale - 1) + 1, y: scaleL * CGFloat(titleScale - 1) + 1)
            rightBtn.transform = CGAffineTransform.init(scaleX: scaleR * CGFloat(titleScale - 1) + 1, y: scaleR * CGFloat(titleScale - 1) + 1)
            rightBtn.setTitleColor(titleColor, for: .normal)
            leftBtn.setTitleColor(titleSelectedColor, for: .normal)
            //移动线
            let x1 :CGFloat = radioBtn.center.x - btnW/3 + scaleR * btnW
            titleBtnBottomLine.frame = CGRect.init(x: x1, y: titleScrollViewH - 3, width: btnW*2/3, height: 3)
        }
    }
}

