var last_send = 0;
var last_position = {
    x: 255,
    y: 255
};
var interval = 1000;

function handle_click(evt) {
    create_request(evt.layerX, evt.layerY);
}

function handle_touch(evt) {
    evt.preventDefault();
    if (evt.touches.length > 0) {
        last_touch = evt.touches[evt.touches.length - 1];
        create_request(last_touch.clientX, last_touch.clientY);
    }
}

function handle_touchend(evt) {
    fetch('/stop', {
        method: 'POST'
    }).then((res) => console.log(res));
}

function create_request(x, y) {
    current = Date.now();
    elapsed = current - last_send;

    width = window.innerWidth;
    height = window.innerHeight;

    scaled_x = 512 / width * x;
    scaled_y = 512 - (512 / height * y);

    if (elapsed < interval) {
        dX = last_position.x - scaled_x;
        dY = last_position.y - scaled_y;
        
        distance = Math.sqrt((dX * dX) + (dY * dY));
        
        document.body.innerHTML = distance;
        if (distance < 50) {
            return;
        }
    }

    last_send = current;
    last_position = {
        x: scaled_x,
        y: scaled_y
    };

    console.log(scaled_x);
    console.log(scaled_y);

    fetch('/move', {
        method: 'POST',
        body: JSON.stringify({
            xs: scaled_x,
            ys: scaled_y
        })
    }).then((res) => console.log(res));
}

document.addEventListener("click", handle_click);
document.addEventListener("touchstart", handle_touch);
document.addEventListener("touchmove", handle_touch, {passive: false});
document.addEventListener("touchend", handle_touchend);

console.log("loaded");