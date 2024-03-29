
START_TIME=`date +%s`

scheme='Puyopuyo'

xcodebuild -workspace Example/Puyopuyo.xcworkspace -scheme $scheme clean build |grep \[0-9].\[0-9]\[0-9]ms | sort -nr > ./compile_time.txt

END_TIME=`date +%s`

EXECUTING_TIME=`expr $END_TIME - $START_TIME`
echo ">>>>> Compile time: ${EXECUTING_TIME}s"