## 标准化生成container配置

> 默认使用`docker.openlaw.cn/tomcat/homolo/tomcat:8.5.37`作为应用image;
> 
> 需要自行配置ROOT.xml中的数据源;
> 
> 需要按需调整deploy-app.v[1-2].sh中是否需要传输到备份服务器上以及发布时war包名称;
> 
> 执行脚本最后一步不需要发布的应用指: probe prototype theme common，不需要时，输入`eg: probe theme`

<html>
  <link rel="stylesheet" type="text/css" href="./player/asciinema-player.css" />
  <asciinema-player src="./player/player.cast cols="146" rows="42"></asciinema-player>
  <script src="./player/asciinema-player.js"></script>
</html>