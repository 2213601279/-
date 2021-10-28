# payManager详细设计文档：

****

作者: `张驰`			时间:`2021年10月16`

****

>实现简单的模块处理

> 使用:
>
> `Springboot` +` LayUIAdmin`+`MySql`

## 事前规范设计模式及拦截

### 1.创建项目并规范项目

````xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.2.2.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
    <groupId>cn.geek51</groupId>
    <artifactId>zrgj-hrm</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>zrgj-hrm</name>
    <description>Demo project for Spring Boot</description>

    <properties>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!-- Junit测试-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
        </dependency>
        <!-- 阿里巴巴DRUID连接池-->
        <dependency>
            <groupId>com.alibaba</groupId>
            <artifactId>druid</artifactId>
            <version>1.1.9</version>
        </dependency>

        <!-- MySql驱动-->
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>5.1.45</version>
        </dependency>

        <!-- JDBC-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>

        <!-- lombok工具 -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>1.18.20</version>
        </dependency>

        <!-- MyBatis集成-->
        <dependency>
            <groupId>org.mybatis.spring.boot</groupId>
            <artifactId>mybatis-spring-boot-starter</artifactId>
            <version>1.3.0</version>
        </dependency>

        <!-- AOP依赖-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-aop</artifactId>
            <optional>true</optional>
        </dependency>

        <!-- FreeMarker依赖-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-freemarker</artifactId>
        </dependency>

        <dependency>
            <groupId>org.mybatis.generator</groupId>
            <artifactId>mybatis-generator-core</artifactId>
            <version>1.3.5</version>
        </dependency>
        <dependency>
            <groupId>commons-codec</groupId>
            <artifactId>commons-codec</artifactId>
            <version>1.15</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
            <plugin>
                <groupId>org.mybatis.generator</groupId>
                <artifactId>mybatis-generator-maven-plugin</artifactId>
                <version>1.3.7</version>
                <configuration>
                    <configurationFile>src/main/resources/generatorConfig.xml</configurationFile>
                </configuration>
            </plugin>
        </plugins>
    </build>

</project>

````



### 2.配置appication.yaml

```yml
server:
  port: 8001

spring:
  application:
    name: couldProvidePayment
  datasource:
    type: com.alibaba.druid.pool.DruidDataSource
    driver-class-name: com.mysql.jdbc.Driver
    url: jdbc:mysql://localhost:3306/pay?useUnicode=true&characterEncoding=utf-8&useSSL=false
    username: root
    password: root

mybatis:
  mapper-locations: classpath:mapper/*.xml
  type-aliases-package: com.hariji.cloudprovidepayment.entities
```



#### 生成模块`payment`:

>![image-20211014095649851](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211014095649851.png)
>
>

#### 生成其他模块:

总体如下:

> ![image-20211016123641393](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016123641393.png)

### 3.编写全局异常处理增强类(返回JSON格式)

```java
/**
 * 全局异常处理增强类
 * 返回JSON
 */
@RestControllerAdvice
public class ErrorControllerAdvice {
    @ExceptionHandler(Exception.class)
    public Object handlerError(Exception ex, HandlerMethod handlerMethod) {
        String exMessage = ex.getMessage();
        String exMeethodName = handlerMethod.getMethod().getName();
        Class exClass = handlerMethod.getBean().getClass();
        String exClassName = exClass.getName();
        return ResponseUtil.general_response( ResponseUtil.CODE_EXCEPTION,
                "ExMessage: "+ exMessage + " ExMethod: " + exMeethodName + " ExClass: " + 
                                             exClassName);
    }
}
```

### 4.Freemarker模板引擎规范:

````java
public class FreemarkerExceptionHandler implements TemplateExceptionHandler {
    @Override
    public void handleTemplateException(TemplateException e, Environment environment, Writer writer) throws TemplateException {
        try {
            writer.write("Freemarker出错啦!");
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}
````

### 5.设置登录拦截器

```java
// 登录检查拦截器
public class LoginInterceptor implements HandlerInterceptor {
    // 登录之前检查, 返回true放行, 否则拦截
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 没有登录
        //System.out.println(UserContext.getCurrentUser());
        if (UserContext.getCurrentUser() == null) {
            response.sendRedirect("/login");
            return false;   // 阻止往后放行
        }
        return true;    // 放行, 放行给下一个拦截器或最终的处理器
    }
}

```

### 6.统一封装结果集(设置状态码)

```java
package cn.geek51.util;

import java.util.HashMap;
import java.util.Map;

public class ResponseUtil {
    public static final int CODE_OK = 200;
    public static final int CODE_ERROR = 402;
    public static final int CODE_EXCEPTION = 405;

    public static Map<Object,Object> general_response(Integer statusCode, String msg, Object data, Map<Object, Object> args) {
        Map<Object, Object> map = new HashMap<>();
        map.put("code", statusCode);
        map.put("msg", msg);
        map.put("data", data);
        if (args != null) {
            for (Map.Entry<Object, Object> entry : args.entrySet()) {
                map.put(entry.getKey(), entry.getValue());
            }
        }
        return map;
    }

    public static Map<Object,Object> general_response(String msg, Object data) {
        return general_response(200, msg, data, null);
    }

    public static Map<Object,Object> general_response(Integer statusCode, String msg) {
        return general_response(statusCode, msg, null, null);
    }

    public static Map<Object,Object> general_response(String msg) {
        return general_response(200, msg, null, null);
    }

    public static Map<Object,Object> general_response(Object data) {
        return general_response(200, "success", data, null);
    }

    public static Map<Object,Object> general_response(String msg, Object data, Map<Object, Object> args) {
        return general_response(200, msg, data, args);
    }

    public static Map<Object,Object> general_response(Integer statusCode, String msg, Map<Object, Object> args) {
        return general_response(statusCode, msg, null, args);
    }

    public static Map<Object,Object> general_response(String msg, Map<Object, Object> args) {
        return general_response(200, msg, null, args);
    }

    public static Map<Object,Object> general_response(Object data, Map<Object, Object> args) {
        return general_response(200, "success", data, args);
    }
}

```

### 7.规范用户操作(登录注销工作)

````java
// 封装当前登录用户的上下文信息
public class UserContext {

    private static final String USER_IN_SESSION = "user_in_session";

    // 获取HttpSession对象
    public static HttpSession getSession() {
        return ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest().getSession();
    }

    public static void setCurrentUser(UserAuth currentUser) {
        if (currentUser == null) {
            getSession().invalidate();
        } else {
            getSession().setAttribute(USER_IN_SESSION, currentUser);
        }
    }

    // 获取当前用户
    public static UserAuth getCurrentUser() {
        return (UserAuth) getSession().getAttribute(USER_IN_SESSION);
    }

    // 进行注销
    public static void doLogout() {
        getSession().invalidate();
    }
}
````

### 8.自定义抽象模板设计模式

> 要求`Dao+domain+Service+controller`

好处统一处理CRUD操作:编辑简单

`AbstractIService<T>`

```java
package cn.geek51.service;

import java.util.List;

public interface AbstractIService<T> {
    /**
     * 增加元素
     * @param object
     */
    int save(T object);

    /**
     * 查询所有元素
     */
    List<T> listAll();
    List<T> listAll(Object object);

    T listOneById(Integer id);

    /**
     * 更改指定元素
     * @param object
     */
    int update(Object object);

    /**
     * 根据ID删除指定元素
     * @param object
     */
    int delete(Object object);

    /**
     * 获取所有数据的总条数
     * @return
     */
    int count();
}

```



## model1:	`payment`

> 开发统一**自定义抽象设计模式**设计

`Mapper`

````xml
<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd"><mapper namespace="cn.geek51.domain.PayWe">    <resultMap id="BaseResultMap" type="cn.geek51.domain.PayWe">        <id column="id" jdbcType="INTEGER" property="id" />        <result column="name" jdbcType="VARCHAR" property="name" />        <result column="good" jdbcType="VARCHAR" property="good" />        <result column="description" jdbcType="VARCHAR" property="description" />        <result column="created_time" jdbcType="TIMESTAMP" property="createdTime" />    </resultMap>    <sql id="Base_Column_List">        id, name, good, description, created_time    </sql>    <select id="selectOneByPrimaryKey" parameterType="java.lang.Integer" resultMap="BaseResultMap">        select        <include refid="Base_Column_List" />        from paywe        where id = #{id,jdbcType=INTEGER}    </select>    <select id="selectAllByParams" resultMap="BaseResultMap">        select <include refid="Base_Column_List" /> FROM paywe        <where>            <trim suffixOverrides=",">                <if test="id != null">                    id=#{id,jdbcType=INTEGER},                </if>                <if test="name != null">                    name=#{name,jdbcType=VARCHAR},                </if>                <if test="good != null">                    good=#{good,jdbcType=VARCHAR},                </if>                <if test="description != null">                    description=#{description,jdbcType=VARCHAR},                </if>                <if test="createdTime != null">                    createdTime=#{createdTime,jdbcType=TIMESTAMP},                </if>            </trim>        </where>        <if test="start != null and count != null">            LIMIT #{start}, #{count}        </if>    </select>    <delete id="deleteOneByParams">        delete from paywe        <where>            <trim suffixOverrides=",">                <if test="id != null">                    id=#{id,jdbcType=INTEGER},                </if>                <if test="name != null">                    name=#{name,jdbcType=VARCHAR},                </if>                <if test="good != null">                    good=#{good,jdbcType=VARCHAR},                </if>                <if test="description != null">                    description=#{description,jdbcType=VARCHAR},                </if>                <if test="createdTime != null">                    createdTime=#{createdTime,jdbcType=TIMESTAMP},                </if>            </trim>        </where>    </delete>    <delete id="deleteOneByPrimaryKey" parameterType="java.lang.Integer">        delete from paywe        where id = #{id,jdbcType=INTEGER}    </delete>    <insert id="insert" parameterType="cn.geek51.domain.PayWe">        insert into paywe (id, name, description,                                good,                                created_time)        values (#{id,jdbcType=INTEGER},                #{name,jdbcType=VARCHAR},                #{good,jdbcType=VARCHAR},                #{description,jdbcType=VARCHAR},                #{createdTime,jdbcType=TIMESTAMP})    </insert>    <insert id="insertSelective" parameterType="cn.geek51.domain.PayWe">        insert into paywe        <trim prefix="(" suffix=")" suffixOverrides=",">            <if test="id != null">                id,            </if>            <if test="name != null">                name,            </if>            <if test="good != null">                good,            </if>            <if test="description != null">                description,            </if>            <if test="createdTime != null">                created_time,            </if>        </trim>        <trim prefix="values (" suffix=")" suffixOverrides=",">            <if test="id != null">                #{id,jdbcType=INTEGER},            </if>            <if test="name != null">                #{name,jdbcType=VARCHAR},            </if>            <if test="good != null">                #{good,jdbcType=VARCHAR},            </if>            <if test="description != null">                #{description,jdbcType=VARCHAR},            </if>            <if test="createdTime != null">                #{createdTime,jdbcType=TIMESTAMP},            </if>        </trim>    </insert>    <update id="updateByPrimaryKeySelective" parameterType="cn.geek51.domain.PayWe">        update paywe        <set>            <if test="name != null">                name = #{name,jdbcType=VARCHAR},            </if>            <if test="good != null">                good = #{good,jdbcType=VARCHAR},            </if>            <if test="description != null">                description = #{description,jdbcType=VARCHAR},            </if>            <if test="createdTime != null">                created_time = #{createdTime,jdbcType=TIMESTAMP},            </if>        </set>        where id = #{id,jdbcType=INTEGER}    </update>    <update id="updateByPrimaryKey" parameterType="cn.geek51.domain.PayWe">        update paywe        set name = #{name,jdbcType=VARCHAR},            good = #{good,jdbcType=VARCHAR},            description = #{description,jdbcType=VARCHAR},            created_time = #{createdTime,jdbcType=TIMESTAMP}        where id = #{id,jdbcType=INTEGER}    </update>    <select id="getCount" resultType="int">        SELECT COUNT(*) FROM paywe;    </select></mapper>
````

### 测试model1`payment`

#### 支付宝订单操作

实验结果:

> 1.验证    **非空**   键入

![image-20211016125137226](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016125137226.png)

> 插入并查看:

![image-20211016125239987](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016125239987.png)

> 改(要求`admin`权限)

![image-20211016163731453](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016163731453.png)

> 删除

![image-20211016125424037](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016125424037.png)

![image-20211016125433116](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016125433116.png)



#### 微信订单操作:

> 验证

![image-20211016163426021](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016163426021.png)

> 缺项验证

![image-20211016163457055](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016163457055.png)

> 查

![image-20211016125810388](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016125810388.png)

> 增

![image-20211016125856444](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016125856444.png)

![image-20211016125914708](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016125914708.png)

> 删

![image-20211016130028727](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016130028727.png)

![image-20211016130038033](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016130038033.png)

> 改`admin`权限

![image-20211016163604489](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016163604489.png)

#### 开发中遇到的BUG：

`405`:

```json
"ExMessage: \r\n### Error querying database. Cause: com.mysql.jdbc.exceptions.jdbc4.MySQLSyntaxErrorException: Unknown column 'created_time' in 'field list'\r\n### The error may exist in file [F:\\springboot-layui-admin-master\\target\\classes\\mapper\\PayWeMapper.xml]\r\n###The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: select           id, name, good, description, created_time       FROM paywe                                  LIMIT ?, ?\r\n### Cause: com.mysql.jdbc.exceptions.jdbc4.MySQLSyntaxErrorException: Unknown column 'created_time' in 'field list'\n; bad SQL grammar []; nested exception is com.mysql.jdbc.exceptions.jdbc4.MySQLSyntaxErrorException: Unknown column 'created_time' in 'field list' ExMethod: getPayWe ExClass: cn.geek51.controller.PayWeController"
```

## model2:`accoutsManager`

**订单统一管理**

```java

```

### 测试实验结果:

> 增

![image-20211016133720952](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016133720952.png)

![image-20211016133734773](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016133734773.png)

> 新增筛选功能

![image-20211016133922999](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016133922999.png)

> 文件导出功能

![image-20211016133944402](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016133944402.png)

![image-20211016133954165](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016133954165.png)

打开文件:

![image-20211016134220913](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016134220913.png)

> 模糊查询

测试:

![image-20211016134256941](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016134256941.png)

> 细化模糊查询精度

1.输入1

![image-20211016163830430](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016163830430.png)

2.输入2:

![image-20211016163855541](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016163855541.png)

## model3:`orderType`

> 目的支持多元化的交易管理

### 测试

> 增

![image-20211016134716081](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016134716081.png)



> 查

![image-20211016134614276](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016134614276.png)

> 关联的模块

![image-20211016134922117](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016134922117.png)

![image-20211016134942996](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016134942996.png)

## model4:`notice`

> 支持导出

![image-20211016164111265](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016164111265.png)

> 添加公告

![image-20211016164301651](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016164301651.png)



​	![image-20211016164312798](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016164312798.png)

> 改

<img src="C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016164409810.png" alt="image-20211016164409810" style="zoom:80%;" />







![image-20211016164442085](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016164442085.png)

## model5:`FileUpLoad`

> 测试上传功能

![image-20211016164600132](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016164600132.png)



> 测试三个组件

![image-20211016164634745](C:\Users\HaRiJi\AppData\Roaming\Typora\typora-user-images\image-20211016164634745.png)



## model6:`charts`

> 1.引入组件





> 2.修改模板





> 3.编写重定向Controller





> 4.新建页面





> 5.测试用例

