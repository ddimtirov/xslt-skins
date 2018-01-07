function setTitle() {
    documentPath = String(window.location);
    documentResource = documentPath.split("/").pop();
    documentFile = documentResource.split("#")[0];
    documentFragment = documentResource.split("#")[1];

    document.title = documentFile;

    documentHeadingElement = document.getElementById("document-heading");
    documentHeadingElement.firstChild.nodeValue = documentFile;
}
