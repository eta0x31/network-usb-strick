//
//  main.ts
//  network-usb-stick
//
//  Created by Peter von der Bey
//  Copyright © 2025 Peter von der Bey. All rights reserved.
//


var rpio = require('rpio');

rpio.open(40, rpio.INPUT, rpio.PULL_UP);

console.log('Pin 40 is currently ' + (rpio.read(40) ? 'high' : 'low'));
