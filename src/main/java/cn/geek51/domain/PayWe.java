package cn.geek51.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.util.Date;

/**
 * @author ： HaRiJi
 * @Date ： 2021/10/15 19:07
 * @Describe :三尺秋水尘不染
 */
@Setter
@Getter
@ToString
public class PayWe {

    private Integer id;

    private String name;

    private String good;

    private String description;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone="GMT+8")
    private Date createdTime;
}
