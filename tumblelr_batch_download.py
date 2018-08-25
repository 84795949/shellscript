#coding:utf-8

import re
import sys
import requests
#import http.cookiejar as cookielib

login_html = "https://www.tangbure.org/subLogin.html"
info_html = "https://www.tangbure.org/user/info.html"
lack_html = "https://vt.tumblr.com/tumblr_"

#利用session保持登录
session = requests.session()

#伪造Header
agent = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36"
header = {
    "Referer": "https://www.tangbure.org/login.html",
    "User-Agent": agent
}

#登陆表单
post_data = {
    'email': 'test@test.com',
    'pass': 'balabala'
}

# 使用session直接post请求
session.post(login_html, data=post_data, headers=header)

#获取tumlr用户列表页面
user_id = ['588605', '587526', '590699', '588705', '496742', '587100', '588245', '251070']
for uid in user_id:
    page = 1
    while page < 500:
        #获取tangbure.org中解析页面并获取html源文件
        video_list = "https://www.tangbure.org/detailVideo.html?currPage="+str(page)+"&id="+str(uid)
        print(video_list)
        response = session.get(video_list)
        source = response.text

        #从html中截取tumblr原网页ID部分，存入列表video_id[]中
        video_id = re.findall("(?!(?:\d+|[a-zA-Z]+)$)=[\da-zA-Z]{17}", source)
        if video_id:
            print("已找到学习资料")
            page += 1
        else:
            print("用户ID"+str(uid)+"没学习资料了一共"+str(page-1)+"页")
            break
        for vid in video_id:
            vid = vid[1:]
            #获取到完整的学习资料下载页面
            video_url = lack_html+vid+".mp4"
            print(video_url)
            url_list = open('vidio-url-list.txt', 'a', encoding="utf-8")
            url_list.write(video_url+'\n')
            url_list.close()
            #学习资料存放位置
            video_file = "g:/python/spiders/video/"+vid+".mp4"
            #开始下载学习资料
            get_video = session.get(video_url)
            with open(video_file, "wb") as code:
                code.write(get_video.content)
                code.close()

