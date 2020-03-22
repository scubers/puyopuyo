#!/bin/bash

cd $(dirname $0)

# 获取当前git状态
diff=`git diff`

# 列举tag
echo "--------tag list--------"
git tag -l --sort=taggerdate|tail -n 10
echo "--------tag list--------"

if [ ${#diff} != 0 ];
then
    echo "====================="
    echo "还有东西没有提交, 是否继续发布版本"
    echo "====================="
fi

echo "根据上面的tag输入新tag"
read version

# 校验pod
pod lib lint --allow-warnings

# 验证失败退出
if [ $? != 0 ];then
    exit -1
fi

# 获取podspec文件名
pod_spec_name=`ls|grep ".podspec$"|sed "s/\.podspec//g"`
echo $pod_spec_name

# 修改版本号
sed -i "" "s/s.version *= *[\"\'][^\"]*[\"\']/s.version=\"$version\"/g" $pod_spec_name.podspec

git commit $pod_spec_name.podspec -m "修改版本号：${version}"
git tag -m "update podspec" $version
git push --tags

# pod repo push PrivatePods --sources=$sources
# pod repo push pods-repo $podSpecName.podspec --sources=master,git@192.168.10.44:ip-ios/pods-repo.git --allow-warnings
# 推送
pod trunk push --allow-warnings