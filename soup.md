# [Bad Soup 毒鸡汤](/soup.html)

<!-- Body -->
<p id="badsoup">有人一笑就很好看，你是一看就挺好笑。</p>

<!-- Footer -->
<script>
  var xhr = new XMLHttpRequest();
  xhr.open('get', 'https://www.7ed.net/soup/api');
  xhr.onreadystatechange = function () {
    if (xhr.readyState === 4) {
      var data = JSON.parse(xhr.responseText);
      var badsoup = document.getElementById('badsoup');
      badsoup.innerText = data.badsoup;
    }
  }
  xhr.send();
</script>
