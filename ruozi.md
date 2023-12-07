# [ruozi](/ruozi.html)

<!-- Body -->
<p id="ruozi">为什么喝消毒水会中毒？我是不是买到假货了——二手弱智</p>

<!-- Footer -->
<script>
  var xhr = new XMLHttpRequest();
  xhr.open('get', 'https://www.7ed.net/ruozi/api');
  xhr.onreadystatechange = function () {
    if (xhr.readyState === 4) {
      var data = JSON.parse(xhr.responseText);
      var ruozi = document.getElementById('ruozi');
      ruozi.innerText = data.ruozi;
    }
  }
  xhr.send();
</script>
