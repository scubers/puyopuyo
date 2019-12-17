//
//  PYProxyChain.h
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PYTarget: NSObject

@property (nonatomic, assign) BOOL retained;

- (nullable id)getValue;

- (instancetype)initWithValue:(id)value retained:(BOOL)retained;

@end

@interface PYProxyChain : NSObject

@property (nonatomic, strong, readonly) NSArray<PYTarget *> *targets;

- (instancetype)initWithTargets:(NSArray<PYTarget *> *)targets;

- (nullable id)targetWithSelector:(SEL)selector;

@end

NS_ASSUME_NONNULL_END
