window.downloadFile = function (base64Data, fileName, contentType) {
    try {
        const link = document.createElement('a');
        link.href = 'data:' + contentType + ';base64,' + base64Data;
        link.download = fileName;
        link.style.display = 'none';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    } catch (error) {
        console.error('Error downloading file:', error);
        throw error;
    }
};