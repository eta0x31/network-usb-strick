//
//  main.ts
//  network-usb-stick
//
//  Created by Peter von der Bey
//  Copyright © 2025 Peter von der Bey. All rights reserved.
//


import rpio from 'rpio';
import chokidar from 'chokidar';

rpio.open(40, rpio.INPUT, rpio.PULL_UP);
console.log('Pin 40 is currently ' + (rpio.read(40) ? 'high' : 'low'));

const watcher = chokidar.watch(
    [
        '/piusb.bin',
        '/mnt/network_share'
    ],{
        persistent      : true,
        ignoreInitial   : true,
        awaitWriteFinish: {
            stabilityThreshold: 1,
            pollInterval      : 1,
        }
    }
);

watcher.on('all', (event, path, stats) => {
    if(path.includes('/.') === true)return;
    console.log( event , path);
});

console.log('👀 Watching for file changes...');
