---
layout: default
---

{% raw %}
<style>
    .selectable {
        -webkit-user-select: all;
        user-select: all;
        cursor: pointer;
        padding: 5px;
        background-color: #b2b2b2;
        border-radius: 5px;
        display: inline-block;
        margin-top: 10px;
    }
</style>
<script src="https://cdn.jsdelivr.net/npm/qrcode@1.4.4/build/qrcode.min.js"></script>
<script>
    function generateQRCode() {
        const urlParams = new URLSearchParams(window.location.search);
        const verificationUri = urlParams.get('verificationUri');
        const userCode = urlParams.get('userCode');
        const login = urlParams.get('login');

        if (!verificationUri || !userCode) {
            return; // 不显示任何内容
        }

        const qrcodeContainer = document.getElementById('qrcode');

        // 如果 `login=1`，只显示用户提示信息
        if (login === '1') {
            const userPrompt = document.createElement('p');
            userPrompt.innerHTML = `请复制代码 <span class="selectable" id="userCode">${userCode}</span> <br>并前往 <a href="${verificationUri}">${verificationUri}</a>，输入代码允许访问并登录微软账户。`;
            qrcodeContainer.appendChild(userPrompt);
        } else {
            // 否则生成二维码
            const currentUrl = window.location.href + '?login=1';
            console.log("currentUrl: ", currentUrl);
            const canvas = document.createElement('canvas');
            QRCode.toCanvas(canvas, currentUrl, function (error) {
                if (error) console.error(error);
            });
            qrcodeContainer.appendChild(canvas);

            // 显示提示信息，使用 <br> 标签进行换行
            const promptMessage = document.createElement('p');
            promptMessage.innerHTML = `请扫描二维码。`;
            qrcodeContainer.appendChild(promptMessage);
        }
    }

    // 检测 JavaScript 是否启用
    window.onload = function() {
        if (typeof document !== 'undefined') {
            generateQRCode();
        } else {
            document.body.innerHTML = '<p>请开启 JavaScript。</p>';
        }
    }
</script>

<div id="qrcode"></div>

{% endraw %}
