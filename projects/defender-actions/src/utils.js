exports.waitTx = async function (txPromise, label = "") {
    return await txPromise.then(
        async (pendingTx) => {
            //console.log(`${label} executing, waiting for confirm...`)
            const receipt = await pendingTx.wait();
            if (receipt.status === 1) {
                console.log(`${label}`, "sucess");
                return receipt;
            } else {
                console.log(`${label}`, "fail");
                process.exit();
            }
        },
        (error) => {
            console.error(`failed to execute transaction ${label} , error: ${error}`)
            process.exit();
        }
    );
}