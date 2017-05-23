//
//  ViewController.swift
//  LearnObjectMapper
//
//  Created by shuoliu on 2017/4/24.
//  Copyright © 2017年 shuoLiu. All rights reserved.
//

import UIKit

class Result: Mappable {
    var result: [Person]?
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        result <- map["result"]
    }
}

class Person: Mappable {
    var name: String?
    var age: Int?
    
    required init?(map: Map) {}
    
    init() {
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        age <- map["age"]
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /*
     JSON与model互转流程：
     1. 构建一个Mapper<Result> 并调用map(_: [String: Any]) -> N? 函数实现转变；
     2. 调用map(_: [String: Any]) -> N?时，内部会先生成一个Map；
     3. 根据上一个步骤生成的Map对象 调用Result中的required init?(map: Map)构建一个Result对象；
     4. 根据上一个步骤构建的Result对象，调用其func mapping(map: Map)函数；
     5. 调用func mapping(map: Map) 根据一个个的 <- 操作符实现了一个个属性值与JSON中的一个个key value的相互转变。
     */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let personJson: [String: Any] = ["result": [["name": "xiaoMing", "age": 18], ["name": "xiaoHong", "age": 17]]]
        let persons1 = Mapper<Result>().map(JSON: personJson)
        persons1?.result?.forEach({ (per) in
            debugPrint(per.name ?? "")
        })
        //  以下三种JSON->Model方式均可行
        /*
        let result: Result? = Mapper().map(JSON: personJson)
        let result1 = Mapper<Result>().map(JSON: personJson)
        let result2 = Result(JSON: personJson)
         */
        
        let persons: [Person]? = Result(JSON: personJson)?.result
        print(persons?.count ?? 0)
        
        let personZhang = Person()
        personZhang.name = "zhangSan"
        let json = Mapper<Person>(shouldIncludeNilValues: true).toJSON(personZhang)
        print("json = \(json)")
        
        let json1 = personZhang.toJSON()
        print("json1 = \(json1)")
        
    }


}

