<!-- 微信訂單管理-->
<!DOCTYPE html>
<html lang="en">
<head>
    <script src="static/js/jquery-3.4.1.min.js"></script>
    <script src="static/layui/layui.js"></script>
    <link rel="stylesheet" href="static/layui/css/layui.css">
</head>
<body>

<script type="text/html" id="payWe-insert">
    <form class="layui-form" method="post">
        <div class="layui-form-item" style="padding-right: 50px">
            <label class="layui-form-label">公众账号ID</label>
            <div class="layui-input-block">
                <input id="payWe-name" type="text" name="name" required  lay-verify="required" placeholder="格式: SYN1010或 SYN`Hariji`" autocomplete="off" class="layui-input">
            </div>
        </div>

        <div class="layui-form-item layui-form-text" style="padding-right: 50px">
            <label class="layui-form-label">商户ID</label>
            <div class="layui-input-block">
                <input id="payWe-good" name="description" placeholder="商户ID 以 T+数字为准..." class="layui-input">
            </div>
        </div>

        <div class="layui-form-item layui-form-text" style="padding-right: 50px">
            <label class="layui-form-label">签名</label>
            <div class="layui-input-block">
                <input id="payWe-description" name="description" placeholder="请输入签名:....." class="layui-input">
            </div>

        </div>

<#--        新增的-->
        <div class="layui-form-item layui-form-text" style="padding-right: 50px">
            <label class="layui-form-label">备注信息</label>
            <div class="layui-input-block">
                <textarea id="payWe-sign" name="description" placeholder="请输入备注..." class="layui-textarea"></textarea>
            </div>
        </div>
    </form>

</script>

<table class="layui-hide" id="payWe-table" lay-filter="payWe-table"></table>

<script type="text/html" id="toolbar">
    <div class="layui-btn-container">
        <button class="layui-btn layui-btn-sm" lay-event="addDept">添加订单（微信）</button>
    </div>
</script>

<script type="text/html" id="barTpl">
    <a class="layui-btn layui-btn-xs" lay-event="edit">保存</a>
    <a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="del">删除</a>
</script>

<script>
    layui.use('table', function(){
        var table = layui.table;

        table.render({
            elem: '#payWe-table',
            url:'/payWe',
            toolbar: '#toolbar',
            parseData: function (res) {
                console.log(res);
                return {
                    "code": 0,
                    "msg": "",
                    "count": res.size,
                    data: res.data
                }
            }
            ,cols: [[
                {field:'id', width:80, title: 'ID'},
                {field:'name', width:150, title: '公众账号ID', edit: true},
                {field:'goods', width:150, title: '商户ID', edit: true},
                {field:'description', width:120, title:'签名', edit: true},
                {field:'createdTime', width:180, title: '创建时间', sort: true},
                {fixed: 'right', width:150, align:'center', toolbar: '#barTpl'}
            ]]
            ,page: true
        });

        table.on('toolbar(payWe-table)', function (obj) {
            var data = obj.data; //获得当前行数据
            var layEvent = obj.event; //获得 lay-event 对应的值（也可以是表头的 event 参数对应的值）
            var tr = obj.tr; //获得当前行 tr 的DOM对象
            switch(obj.event){
                case 'addDept':
                    layer.open({
                        btn: '新建',
                        title: '添加新微信訂單',
                        content: $("#payWe-insert").text(),
                        offset: 'c',
                        area: ["500px", "300px"],
                        yes: function () {
                            var name = $("#payWe-name").val();
                            var description = $("#payWe-description").val();
                            var sign = $("#payWe-sign").val();
                            var good = $("#payWe-good").val();
                            if (name.length <= 0  || good.length <=0 || description.length <= 0 || sign.length <= 0) {
                                if (name.length <= 0) {
                                    layer.tips('公众账号ID不能为空', '#payWe-name',  {
                                        tipsMore: true
                                    });
                                }
                                // 新增
                                if (good.length <= 0) {
                                    layer.tips('商品ID不能为空', '#payWe-good',  {
                                        tipsMore: true
                                    });
                                }
                                if (description.length <= 0) {
                                    layer.tips('签名不能为空', '#payWe-description', {
                                        tipsMore: true
                                    });
                                }
                                if (sign.length <= 0) {
                                    layer.tips('备注信息不能为空', '#payWe-sign', {
                                        tipsMore: true
                                    });
                                }

                            } else {
                                // 调用新建API
                                var nowDate = new Date();
                                $.ajax({
                                    url: '/payWe',
                                    method: 'post',
                                    data: {
                                        name: name,
                                        good: good,
                                        description: description,
                                        createdTime: nowDate
                                    },
                                    success: function (res) {
                                        console.log(res);
                                        if (res.code == 200) {
                                            // 执行局部刷新, 获取之前的TABLE内容, 再进行填充
                                            var dataBak = [];
                                            var tableBak = table.cache.payWe-table;
                                            for (var i = 0; i < tableBak.length; i++) {
                                                dataBak.push(tableBak[i]);      //将之前的数组备份
                                            }
                                            dataBak.push({
                                                name: $("#payWe-name"),
                                                good:$("#payWe-good"),
                                                description: $("#payWe-description"),
                                                createdTime: nowDate
                                            });
                                            //console.log(dataBak);
                                            table.reload("payWe-table",{
                                                data:dataBak   // 将新数据重新载入表格
                                            });
                                            layer.msg('新建微信訂單成功', {icon: 1});
                                        } else {
                                            layer.msg('新建微信訂單失败', {icon: 2});
                                        }
                                    }
                                });
                            }
                        }
                    });
            }
        });

        //监听工具条(右侧)
        table.on('tool(payWe-table)', function(obj){ //注：tool是工具条事件名，test是table原始容器的属性 lay-filter="对应的值"
            var data = obj.data; //获得当前行数据
            var layEvent = obj.event; //获得 lay-event 对应的值（也可以是表头的 event 参数对应的值）
            var tr = obj.tr; //获得当前行 tr 的DOM对象
            if(layEvent === 'edit'){ //编辑
                // 发送更新请求
                $.ajax({
                    url: '/payWe',
                    method: 'put',
                    data: JSON.stringify({
                        id: data.id,
                        good: data.good,
                        name: data.name,
                        description: data.description
                    }),
                    contentType: "application/json",
                    success: function (res) {
                        console.log(res);
                        if (res.code == 200) {
                            layer.msg('更改微信訂單信息成功', {icon: 1});
                            obj.update({
                                name: data.name,
                                good: data.good,
                                description: data.description
                            });
                        } else {
                            layer.msg('更改微信訂單信息失败', {icon: 2});
                        }
                    }
                });
            } else if (layEvent == 'del') {
                layer.confirm('删除微信訂單' + data.name + '?', {skin: 'layui-layer-molv',offset:'c', icon:'0'},function(index){
                    obj.del(); //删除对应行（tr）的DOM结构，并更新缓存
                    layer.close(index);
                    //向服务端发送删除指令
                    $.ajax({
                        url: '/payWe/' + data.id,
                        type: 'delete',
                        success: function (res) {
                            console.log(res);
                            if (res.code == 200) {
                                layer.msg('删除微信訂單成功', {icon: 1, skin: 'layui-layer-molv', offset:'c'});
                            } else {
                                layer.msg('删除微信訂單失败', {icon: 2, skin: 'layui-layer-molv', offset:'c'});
                            }
                        }
                    })
                });
            }
        });

    });
</script>
</body>
</html>