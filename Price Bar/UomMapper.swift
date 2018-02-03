//
//  UomMapper.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/24/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class UomMapper {
    class func mapper(from fbModel: FBUomModel) -> CDUomModel {
        return CDUomModel(id: fbModel.id,
                          name: fbModel.name,
                          parameters: fbModel.parameters)
    }

    class func transform(from fbModelList: [FBUomModel]) -> [CDUomModel] {
        return fbModelList.map { fbUom in
            mapper(from: fbUom)
        }
    }
    
    class func mapper(from cdModel: CDParameter) -> Parameter {
        
        guard
        let maxValue = cdModel.maxValue,
        let step = cdModel.step,
        let suffix = cdModel.suffix,
            let viewMultiplicator = cdModel.viewMultiplicator else {
                fatalError("Cant parse CDParameter")
        }
        
        
        return Parameter(maxValue: maxValue,
                         step: step,
                         suffix: suffix,
                         viewMultiplicator: viewMultiplicator)
        
    }
    
    class func transform(from cdModeList: [CDParameter]) -> [Parameter] {
        
        return cdModeList.map { parameter in
            mapper(from: parameter)
        }
        
    }
    
    
    class func mapper(from parameter: Parameter) -> CDParameter {
        
        
        return CDParameter(maxValue: parameter.maxValue,
                           step: parameter.step,
                           suffix: parameter.suffix,
                           viewMultiplicator: parameter.viewMultiplicator)
        
    }
    class func transform(from parameterList: [Parameter]) -> [CDParameter] {
        
        return parameterList.map { parameter in
            mapper(from: parameter)
        }
        
    }
    
    
}


