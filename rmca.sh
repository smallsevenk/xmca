
#!/bin/bash

# 递归查找lib目录下的所有文件，去除文件名中的ca_前缀
find lib -type f -name "*" | while read file; do
    # 获取文件所在目录
    dir=$(dirname "$file")
    # 获取文件名（不含路径）
    filename=$(basename "$file")
    # 去除ca_前缀
    new_filename="${filename#ca_}"
    # 如果文件名确实有变化，则执行重命名
    if [ "$filename" != "$new_filename" ]; then
        mv -v "$file" "$dir/$new_filename"
    fi
done

echo "ca_前缀去除完成"
