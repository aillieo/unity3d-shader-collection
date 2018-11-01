#!/bin/bash

echo start processing ...

#脚本所在路径
basepath=$(cd `dirname $0`; pwd)

#Assets路径 各文件夹的根目录
folderoot=$basepath/Assets

rmname="README.md"

folders=()

echo collecting ...

# 获取所有包含README.md的文件夹 保存到数组
for subpath in $folderoot/*; do
    if test -d $subpath
    then
    	if test -e $subpath/$rmname
    	then
    		foldername=${subpath##*/}
	    	folders=("${folders[@]}" $foldername)
		fi 
	fi
done

filecnt=${#folders[@]}
echo $filecnt files collected !

# 重置主README.md
mainfile=$basepath/$rmname
rm -f $mainfile
touch $mainfile

echo reset $rmname

# 逆序遍历保存的文件夹 提取REAMME.md
for(( i=$filecnt-1;i>=0;i--)) do
	folder=${folders[i]}
	filename=$folderoot/$folder/$rmname
	echo processing ... $filename
	while read line
	do
		# 替换掉 "../../GALLERY" 这样的路径 并将内容追加到主README.md 
		echo $line | sed -e 's/..\/..\/GALLERY/GALLERY/g' >> $mainfile
	done < $filename
	echo '***' >>$mainfile
done

echo finished!
