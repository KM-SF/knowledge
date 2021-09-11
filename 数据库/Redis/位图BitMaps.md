# 位图BitMaps

+ bitmaps：本身不是一种数据类型，实际上它就是字符串，但是它可以对字符串的位进行操作
+ bitmaps：单独提供了一套命令，所以redis中使用bitmaps和使用字符串的方式不太一样。可以把bitmaps想象成一个以位为单位的数组，数组的每个单元只能存储0和1，数组的下标在bitmpas中叫做偏移量
+ 注意：很多应用的用户ID以一个指定的数字（例如1000）开头，直接将用户id和bitmaps的偏移量对应势必造成大量的浪费，通常的做法是每次做setbit操作的时候将用户减去这个指定数字

# 常用命令

+ setbit <key> <offset><value>：设置bitmaps某个偏移量的值（0或者1），偏移量从0开始
+ getbit <key><offset>：获取bitmpas某个偏移量的值
+ bitcount：统计字符串被设置为1的bit数量。
+ bitop and/or/not/xor <deskey> [key...]：bitop是一个复合操作，它可以做多个bitmaps的and（交集），or（并集），not（非），xor（异或）操作并将结果保存在deskey中。

