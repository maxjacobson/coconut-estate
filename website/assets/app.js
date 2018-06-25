var hello = document.createElement('p')
hello.appendChild(document.createTextNode('Hello from JS'))
document.querySelectorAll('body')[0].appendChild(hello)

var goodbye = document.createElement('p')
goodbye.appendChild(document.createTextNode('Goodbye from JS'))
document.querySelectorAll('body')[0].appendChild(goodbye)
