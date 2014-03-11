#! /bin/bash

loop=0
while ( true )
do
    for((i=0;i<30;i++))
    do
        status=`nova --no-cache list  | grep resize-test | awk '{print $6}'`
        flavor=`nova --no-cache show resize-test | grep flavor | sed 's/(//g'  | sed 's/)//g' | awk '{print $5}'`
        if [ ${flavor} == 428 ]; then
            flavor=429
        else
            flavor=428
        fi

        if [ ${status} == 'ACTIVE' ]; then
            echo "nova resize resize-test ${flavor}"
            nova --no-cache resize resize-test ${flavor}
            i=70
        else
            echo "error instance status: ${status}, sleeping 5s..."
            sleep 5
        fi
    done

    ((loop+=1))
    echo "end loop: ${loop}, sleeping 100s..."
    sleep 100
done
