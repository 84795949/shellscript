change_and_check(){
file_path=apps/common/pdf.js/viewer.jsp
for i in `ls `;do
	if [ -d $i ];then
		if [ -f $i/$file_path ] ;then
			echo -e "\n\033[31m ----------------------------------------------------------------------------------------------------------------------------------------  \033[0m"
			ls $i/$file_path
			cat viewer.jsp > $i/$file_path
			if [ $? == 0 ];then
				echo 状态码:$?
			head -n 1 $i/$file_path
			tail -n 2 $i/$file_path
			else
				echo 状态码:$?
				echo -e "\033[31m ERROR!\033[0m"
			fi
			diff $i/$file_path ./viewer.jsp
			echo -e "\033[31m ----------------------------------------------------------------------------------------------------------------------------------------  \033[0m\n"
		fi
	fi
done
}

change_and_check|tee ./change_viewer_jsp.log
