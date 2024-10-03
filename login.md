<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>二维码登录</title>
    <script src="https://cdn.jsdelivr.net/npm/qrcodejs@1.0.0/qrcode.min.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            background-color: #f4f4f9;
        }
        #qrcode {
            margin: 20px 0;
        }
        .hidden {
            display: none;
        }
    </style>
</head>
<body>
    <!-- 提示用户开启 JavaScript -->
    <noscript>
        <style>
            #content {
                display: none;
            }
        </style>
        <p style="color: red;">此页面需要 JavaScript 才能正常工作，请启用 JavaScript。</p>
    </noscript>

    <div id="content" class="hidden">
        <div id="qrcode"></div>
        <p id="message"></p>
    </div>

    <script>
        // 获取URL参数
        function getQueryParams() {
            const params = {};
            window.location.search.substr(1).split('&').forEach(function(part) {
                const [key, value] = part.split('=');
                params[decodeURIComponent(key)] = decodeURIComponent(value);
            });
            return params;
        }

        // 初始化
        const params = getQueryParams();
        const contentDiv = document.getElementById('content');
        const qrcodeDiv = document.getElementById('qrcode');
        const messageP = document.getElementById('message');

        // 如果包含 verificationUri 和 userCode 参数
        if (params.verificationUri && params.userCode) {
            // 如果 phone 参数为 true，则提示复制 userCode 并前往 verificationUri
            if (params.phone === 'true') {
                contentDiv.classList.remove('hidden');
                messageP.textContent = `请复制此代码：${params.userCode}，并点击前往 ${params.verificationUri} 登录。`;
                qrcodeDiv.classList.add('hidden'); // 隐藏二维码
            } else {
                // 否则生成二维码
                const currentUrl = window.location.origin + window.location.pathname;
                const qrUrl = `${currentUrl}?verificationUri=${encodeURIComponent(params.verificationUri)}&userCode=${encodeURIComponent(params.userCode)}&phone=true`;
                contentDiv.classList.remove('hidden');
                messageP.textContent = `请扫描二维码：\nverificationUri：${params.verificationUri}\nuserCode：${params.userCode}`;
                new QRCode(qrcodeDiv, {
                    text: qrUrl,
                    width: 200,
                    height: 200
                });
            }
        }
    </script>
</body>
</html>
