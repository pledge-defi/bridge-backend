function get_mplgr_price() {
    const https = require("https");
    https.get("https://www.baidu.com", resp => {
        // let data = "";
        // resp.on("data", function(chunk) {
        //     data += chunk;
        // });
        // resp.on("end", () => {
        //     sendDataToWeb(JSON.parse(data).url);
        // });
        // resp.on("error", err => {
        //     console.log(err.message);
        // });
        const price = 0.01;
        console.log('current mplgr price is = ', price);
    });
}