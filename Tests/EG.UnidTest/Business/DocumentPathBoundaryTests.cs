using EG.Common.Util;

namespace EG.UnidTest.Business;

public sealed class DocumentPathBoundaryTests
{
    [Theory]
    [InlineData("../Documentos-ajenos/archivo.pdf")]
    [InlineData("../archivo.pdf")]
    [InlineData("..")]
    [InlineData(".")]
    public void ParentAndSiblingDirectoriesAreRejected(string path)
    {
        var root = Path.Combine(Path.GetTempPath(), "Documentos");
        Assert.Throws<UnauthorizedAccessException>(() => DocumentPathBoundary.Resolve(root, path));
    }

    [Fact]
    public void AbsolutePathIsRejectedEvenWhenItPointsInsideRoot()
    {
        var root = Path.Combine(Path.GetTempPath(), "Documentos");
        Assert.Throws<UnauthorizedAccessException>(() => DocumentPathBoundary.Resolve(root, Path.Combine(root, "archivo.pdf")));
    }

    [Fact]
    public void NestedDocumentPathIsAcceptedWithoutTouchingDisk()
    {
        var root = Path.Combine(Path.GetTempPath(), "Documentos");
        Assert.Equal(Path.Combine(root, "Almacen", "archivo.pdf"),
            DocumentPathBoundary.Resolve(root, Path.Combine("Almacen", "archivo.pdf")));
    }

    [Fact]
    public void VolumeRootRemainsAValidConfiguredRoot()
    {
        var root = Path.GetPathRoot(Path.GetTempPath())!;
        Assert.Equal(Path.Combine(root, "archivo.pdf"), DocumentPathBoundary.Resolve(root, "archivo.pdf"));
    }
}
