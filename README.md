## 该版本是sphinx的docker版

```
docker pull w303972870/sphinx
```

|软件|版本|
|:---|:---|
|sphinx|3.0.3|


#### 启动命令示例：为了初始化必须指定一个默认的root密码MYSQL_ROOT_PASSWORD

```
docker run -dit -p 9002:9002  -p 9312:9312 -p 9306:9306 -v /data/sphinx/:/data/ -v /etc/localtime:/etc/localtime -e IS_FIRST_INDEXER=yes docker.io/w303972870/sphinx
docker run -dit -p 9002:9002  -p 9312:9312 -p 9306:9306 -v /data/sphinx/:/data/ -v /etc/localtime:/etc/localtime docker.io/w303972870/sphinx
```

|变量|解释|
|:---|:---|
|SKIP_INIT_INDEXER|跳过初始化索引，直接启动sphinx服务seached|
|IS_FIRST_INDEXER|为yes时新建索引，否则相当于--rotate重建索引，暂时弃用！！|
|BUILD_INDEX|建立的索引名称，不传值时默认--all|
|MERGE|要合并的索引名称字符串，空格间隔，例如“index1 inde2”,如果存在以上建立索引需求，先执行以上建立索引再执行这个合并|


### 开放端口9002 9312 9306


### Sphinx配置文件目录：/data/sphinx/etc
### Sphinx日志目录：/data/sphinx/logs
### Sphinx索引目录：/data/sphinx/data
### supervisor配置文件目录：/data/supervisor/etc/
### supervisor日志目录：/data/supervisor/logs/
### crontab目录：/data/crontab/

### 配置文件名：/data/sphinx/etc/sphinx.conf
### 配置文件名：/data/supervisor/etc/supervisord.conf



### 我的/data/sphinx/目录结构
```
/data/sphinx/
├── crontab
├── sphinx
│   ├── data
│   ├── etc
│   │   └── sphinx.conf
│   └── logs
└── supervisor
    ├── etc
    │   └── supervisord.conf
    └── logs
```


**附上一个简单的sphinx.cnf配置文件**

```
source article
{
        type                    = mysql
        sql_host                = 192.168.12.2
        sql_user                = root
        sql_pass                = 123456
        sql_db                  = articlesplider
        sql_port                = 3306  # optional, default is 3306
        sql_query_pre   = SET NAMES utf8 
    sql_query_pre   = SET SESSION query_cache_type=OFF  
    sql_query       = SELECT ArticleID, ArticleTitle,ArticleAuthor, ArticleUrl, ArticleTime, ArticleSource,ArticleConver,ArticleType,ArticleDowntime,ArticleDesc FROM splider_article  
        sql_attr_uint           = ArticleSource
        sql_field_string        = ArticleTitle
        sql_field_string        = ArticleAuthor
        sql_field_string        = ArticleUrl 
        sql_field_string        = ArticleConver
        sql_field_string        = ArticleType
        sql_field_string        = ArticleDesc 
        sql_attr_timestamp      = ArticleTime
        sql_attr_timestamp      = ArticleDowntime
        sql_ranged_throttle     = 0  
        #sql_attr_uint              = group_id
        #sql_attr_timestamp         = date_added
        #sql_ranged_throttle    = 0
}
index article 
{  
        source = article 
        path = /data/sphinx/data/article
        mlock = 0  
        morphology = none  
        min_word_len = 1  
        html_strip = 1  

        #charset_table非常重要

}
searchd
{

        #php
        listen              = 9312
        #mysql
        listen              = 9306:mysql41
        log                             = /data/sphinx/logs/searchd.log
        query_log                   = /data/sphinx/logs/query.log
        query_log_format    = sphinxql
        read_timeout            = 5
        client_timeout          = 300
        max_children            = 30
        persistent_connections_limit    = 30
        pid_file                = /data/sphinx/logs/searchd.pid
        seamless_rotate         = 1
        preopen_indexes         = 1
        unlink_old              = 1
        max_packet_size         = 8M
        max_filters             = 256
        max_filter_values       = 4096
        max_batch_queries       = 32
        workers                 = threads # for RT to work
        binlog_path =/data/sphinx/logs/
}

```


**附上一个简单的supervisord.cnf配置文件**

```
[inet_http_server]
port=127.0.0.1:9002
username=root
password=123456

[supervisord]
nodaemon=true
logfile=/data/supervisor/logs/supervisord.log ; 
pidfile=/data/supervisor/supervisord.pid ; 
childlogdir=/data/supervisor/logs ;

[program:crontab]
command=/bin/bash -c "source /etc/sysconfig/crond && exec /usr/sbin/crond -n $CRONDARGS"
stopsignal=QUIT
autostart=true ;
autorestart=true ;

[program:sphinx]
command=/usr/local/sphinx/bin/searchd --config /data/sphinx/etc/sphinx.conf
stopsignal=QUIT
autostart=true ;
autorestart=true ;

```
