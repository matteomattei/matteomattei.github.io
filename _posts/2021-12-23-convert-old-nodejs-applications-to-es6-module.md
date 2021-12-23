---
title: Convert old NodeJs applications to ES6 module
description: A very quick guide on how to convert old Nodejs applications to ES6 module
author: Matteo Mattei
layout: post
permalink: /convert-old-nodejs-application-to-es6-module/
img_url:
categories:
  - nodejs
---

Nowadays every Nodejs application should be converted to ES6 module because it brings several benefits:

- Modules may be executed any number of times, but are loaded only once, thus improving performance.
- Module scripts may be shared by multiple applications.
- Modules help identify and remove naming conflicts.

The biggest difference between standard javascript library and an ES6 module is how we include a library (which can be either within your project or external).
The standard classic way is to use **const library = require('library-name')** but with ES6 modules we have to use **import library from 'library-name'**.

In order to support the **import** keyword you have to add the following line to the _package.json_ of your application:

```
"type": "module"
```

In this way you are telling npm that your application is a pure ES6 module.

Then you have to change all _require(xxx)_ statements with _import xxx from 'yyy'_.
In case you want to use an external library which is not a pure ES6 module you can always include it with this syntax:

```
import theNameYouWant from 'official-library-name'
```

In case you want to use a library which is placed inside your application you can use this syntax:

```
import theNameYouWant from './path/to/mylibrary.js'
```

And `mylibrary.js` can export a default object with all functions like this:

```
import axios from 'axios';

export default {
	run: function(){
		console.log('run');
	},
	sum: function(x, y){
		console.log(`Sum is ${x+y}`);
	},
	get: async function(){
		return await axios.get('https://github.com/matteomattei/matteomattei.github.io/raw/master/public/logo_professtional.jpg');
	}
}
```

And can be used in this way:

```
import mylib from './path/to/mylibrary.js'

mylib.run(); // prints 'run'
mylib.sum(2,3); // prints 'Sum is 5';
let getResult = await mylib.get();
console.log(Buffer.from(getResult.data).length); // prints the size of the image
```

You can also export single functions from your library like this:

```
import axios from 'axios';

export function run() {
  console.log("run");
}
export function sum(x, y) {
  console.log(`Sum is ${x + y}`);
}
export async function get() {
  return await axios.get(
    "https://github.com/matteomattei/matteomattei.github.io/raw/master/public/logo_professtional.jpg"
  );
}
```

In this case you have to use it in this way:

```
import * as mylib from './path/to/mylibrary.js'

mylib.run(); // prints 'run'
mylib.sum(2,3); // prints 'Sum is 5';
let getResult = await mylib.get();
console.log(Buffer.from(getResult.data).length); // prints the size of the image
```

Otherwise you can selectively import only the function you need:

```
import {run, sum, get} from './path/to/mylibrary.js'

run(); // prints 'run'
sum(2,3); // prints 'Sum is 5';
let getResult = await get();
console.log(Buffer.from(getResult.data).length); // prints the size of the image
```

Remember:

- You have to add **type: "module"** to your package.json file.
- You can use **await** directly in your main module without a wrap of an async function.
- Your code must be implicitly _strict_.
