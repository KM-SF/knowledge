# 地理信息Geospatial

+ 该类型就是元素的2维坐标，在地图上就是经纬度。
+ 提供了经纬度设置，查询，范围查询，距离查询，经纬度hash等常见操作

# 常见命令

+ geoadd <key> <longitude><latitude><member> [<longitude><latitude><member>...]：添加地理位置（经度，纬度，名称）**有效经度为-180到180。有效纬度为-85.05112878到85.05112878**
+ geopos <key><member> [<member>...]：获取指定地区的坐标值
+ geodist <key><member1><member2> ：获取两个位置之间的直线距离
+ georadius <key><longitude><latitude><radius>：以给定经纬度为中心，找出某一个半径内的元素

