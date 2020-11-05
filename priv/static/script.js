document.addEventListener("DOMContentLoaded", () => {
  window.canvas = document.getElementById("canvas");
  window.ctx = canvas.getContext('2d');

  const xmin = window.xs.reduce((min, val) => ((val < min) ? val : min), 3600);
  const xmax = window.xs.reduce((max, val) => ((val > max) ? val : max), 0);
  const ymin = window.ys.reduce((min, val) => ((val < min) ? val : min), 3600);
  const ymax = window.ys.reduce((max, val) => ((val > max) ? val : max), 0);

  window.drawParams = {
    xmin, xmax, ymin, ymax,
    xmargin: 0.1*(xmax - xmin),
    ymargin: 0.1*(ymax - ymin)
  };

  // draw canvas bounds
  ctx.fillText(`${drawParams.xmin.toFixed(2)}, ${drawParams.ymin.toFixed(2)}`, 10, 10);
  ctx.fillText(`${drawParams.xmax.toFixed(2)}, ${drawParams.ymax.toFixed(2)}`, canvas.width - 50, canvas.height - 2);

  for (let i = 0; i < xs.length; i++) {
    for (let j = 0; j < ys.length; j++) {
      let x = lerp(xs[i], drawParams.xmin - drawParams.xmargin, drawParams.xmax + drawParams.xmargin, 0, canvas.width);
      let y = lerp(ys[j], drawParams.ymin - drawParams.ymargin, drawParams.ymax + drawParams.ymargin, 0, canvas.height);

      // draw connecting boxes and triangles
      if (i > 0 && j > 0) {
        let x2 = lerp(xs[i-1], drawParams.xmin - drawParams.xmargin, drawParams.xmax + drawParams.xmargin, 0, canvas.width);
        let y2 = lerp(ys[j-1], drawParams.ymin - drawParams.ymargin, drawParams.ymax + drawParams.ymargin, 0, canvas.height);
        ctx.strokeStyle = '#ddd';
        ctx.strokeRect(x2, y2, (x-x2), (y-y2));
        ctx.beginPath();
        ctx.moveTo(x2, y2);
        ctx.lineTo(x, y);
        ctx.moveTo(x, y2);
        ctx.lineTo(x2, y);
        ctx.stroke();
      }

      // draw samples
      let value = Math.round(window.values[i][j]);
      ctx.fillStyle = (value > 600) ? 'gray' : 'black';
      ctx.fillText(value, x+1, y-1);
    }
  }

  ctx.strokeStyle = "black";
  drawContour();
});

function lerp(x, a0, a1, b0, b1) {
  return (x - a0)/(a1 - a0)*(b1 - b0) + b0;
}

function x(x) {
  return Math.floor(lerp(x, drawParams.xmin - drawParams.xmargin, drawParams.xmax + drawParams.xmargin, 0, canvas.width));
}

function y(y) {
  return Math.floor(lerp(y, drawParams.ymin - drawParams.ymargin, drawParams.ymax + drawParams.ymargin, 0, canvas.height));
}

function drawLine(x0, y0, x1, y1) {
  ctx.beginPath();
  ctx.moveTo(x(x0), y(y0));
  ctx.lineTo(x(x1), y(y1));
  ctx.stroke();
}
