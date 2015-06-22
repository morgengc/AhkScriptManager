#####################################################
# 将输入文件按照列对齐方式重排，默认分隔符为: 空格, Tab, 逗号, 分号
# 用法：gawk -f alignColumn.awk urfile
#
# gaochao.morgen@gmail.com
# 2013/5/16
#####################################################

BEGIN {
	FS = "[ \t]+";
}
{
    fpl[FNR] = NF;
    for (i=1; i<=NF; i++) {
        data[FNR, i] = $i;
        if (length($i) > max[i]) {
            max[i] = length($i);        # max[i]: 第i行的所有域中，最大域的长度
        }
    }
}
END { 
    for (l=1; l<=FNR; l++) {            # 处理END块时，已经读到文件最后一行. 因此此时的FNR就是文件的行数
        for (i=1; i<=fpl[l]; i++) {     # fpl[l]: 第l行的域数. 域：每行由FS符号分隔开的都是域
            fmt = "%-" max[i] "s";
            if (i > 1) {
                printf " ";             # 此为每列(除第一列)前默认设置的一个空格
            }
            printf(fmt, data[l, i]);    # data[l,i]: 第l行的第i个域
        }
        printf "\n";
    }
}

