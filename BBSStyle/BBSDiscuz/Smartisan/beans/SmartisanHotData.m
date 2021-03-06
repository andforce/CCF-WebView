//
//  THotData.m
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "SmartisanHotData.h"
#import "SmartisanHotPage.h"
#import "SmartisanHotList.h"


NSString *const kTHotDataPage = @"page";
NSString *const kTHotDataList = @"list";


@interface SmartisanHotData ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation SmartisanHotData

@synthesize page = _page;
@synthesize list = _list;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];

    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
        self.page = [SmartisanHotPage modelObjectWithDictionary:[dict objectForKey:kTHotDataPage]];
        NSObject *receivedTHotList = [dict objectForKey:kTHotDataList];
        NSMutableArray *parsedTHotList = [NSMutableArray array];
        if ([receivedTHotList isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *) receivedTHotList) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedTHotList addObject:[SmartisanHotList modelObjectWithDictionary:item]];
                }
            }
        } else if ([receivedTHotList isKindOfClass:[NSDictionary class]]) {
            [parsedTHotList addObject:[SmartisanHotList modelObjectWithDictionary:(NSDictionary *) receivedTHotList]];
        }

        self.list = [NSArray arrayWithArray:parsedTHotList];

    }

    return self;

}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[self.page dictionaryRepresentation] forKey:kTHotDataPage];
    NSMutableArray *tempArrayForList = [NSMutableArray array];
    for (NSObject *subArrayObject in self.list) {
        if ([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForList addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForList addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForList] forKey:kTHotDataList];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict {
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];

    self.page = [aDecoder decodeObjectForKey:kTHotDataPage];
    self.list = [aDecoder decodeObjectForKey:kTHotDataList];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:_page forKey:kTHotDataPage];
    [aCoder encodeObject:_list forKey:kTHotDataList];
}

- (id)copyWithZone:(NSZone *)zone {
    SmartisanHotData *copy = [[SmartisanHotData alloc] init];

    if (copy) {

        copy.page = [self.page copyWithZone:zone];
        copy.list = [self.list copyWithZone:zone];
    }

    return copy;
}


@end
