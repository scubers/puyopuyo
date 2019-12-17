//
//  PYProxyChain.m
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/17.
//

#import "PYProxyChain.h"

@interface PYProxyChain()
@property (nonatomic, strong) NSArray<PYTarget *> *targets;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PYTarget *> *cache;
@end

@implementation PYProxyChain
- (instancetype)initWithTargets:(NSArray<PYTarget *> *)targets {
    if (self = [super init]) {
        _targets = targets;
        _cache = @{}.mutableCopy;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    PYTarget *target = [self targetWithSelector:aSelector];
    return target != nil;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return [self targetWithSelector:aSelector];
}

- (nullable id)targetWithSelector:(SEL)selector {
    PYTarget *target = _cache[NSStringFromSelector(selector)];
    if (target.getValue != nil) {
        return target.getValue;
    }
    for (PYTarget *t in _targets) {
        if ([t.getValue respondsToSelector:selector]) {
            _cache[NSStringFromSelector(selector)] = t;
            return t.getValue;
        }
    }
    return nil;
}

@end

@interface PYTarget()
@property (nonatomic, strong) id strongValue;
@property (nonatomic, weak) id weakValue;
@end
@implementation PYTarget

- (instancetype)initWithValue:(id)value retained:(BOOL)retained {
    if (self = [super init]) {
        if (retained) {
            _strongValue = value;
        } else {
            _weakValue = value;
        }
        _retained = retained;
    }
    return self;
}

- (id)getValue {
    return _strongValue ?: _weakValue;
}

@end
