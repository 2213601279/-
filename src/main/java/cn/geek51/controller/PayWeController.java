package cn.geek51.controller;

import cn.geek51.domain.PageHelper;

import cn.geek51.domain.PayWe;
import cn.geek51.service.IPayWeService;
import cn.geek51.util.ResponseUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author ： HaRiJi
 * @Date ： 2021/10/15 19:14
 * @Describe :三尺秋水尘不染
 */
@RestController
public class PayWeController {
    @Autowired
    IPayWeService service;

    // 查询
    @GetMapping("/payWe")
    public Object getPayWe(PageHelper pageHelper) {
        Map<Object, Object> map = pageHelper.getMap();
        List<PayWe> payWeList = service.listAll(map);
        if (map == null) map = new HashMap<>();
        else map.clear();
        map.put("size", service.count());
        return ResponseUtil.general_response(payWeList, map);
    }

    @GetMapping("/payWe/{id}")
    public Object getPayWes(@PathVariable("id") Integer id) {
        PayWe payWe = service.listOneById(id);
        return ResponseUtil.general_response(payWe);
    }

    // 更改
    @PutMapping("/payWe")
    public Object updatePayWe(@RequestBody PayWe payWe) {
        System.out.println(payWe);
        service.update(payWe);
        return ResponseUtil.general_response("success update payWe!");
    }

    // 新建
    @PostMapping("/payWe")
    public Object insertPayWe(PayWe payWe) {
        System.out.println(payWe);
        Integer newId = service.save(payWe);
        return ResponseUtil.general_response(newId);
    }

    // 删除
    @DeleteMapping("/payWe/{id}")
    public Object deletePayWe(@PathVariable("id") Integer id) {
        service.delete(id);
        return ResponseUtil.general_response("success delete PayWe!");
    }
}
