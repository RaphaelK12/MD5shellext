using SharpShell.Attributes;
using SharpShell.SharpContextMenu;
using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using System.Windows.Forms;

namespace MD5shellext
{
    [ComVisible(true)]
    [COMServerAssociation(AssociationType.AllFiles)]
    public class MD5Extension : SharpContextMenu
    {
        protected override bool CanShowMenu() => true;

        protected override ContextMenuStrip CreateMenu()
        {
            var itemGenerateMD5 = new ToolStripMenuItem
            {
                Text = "Generate MD5",
            };
            itemGenerateMD5.Click += (sender, args) => GenerateMD5();

            var menu = new ContextMenuStrip();
            menu.Items.Add(itemGenerateMD5);
            return menu;
        }

        private void GenerateMD5()
        {
            var builder = new StringBuilder();

            foreach(var filePath in SelectedItemPaths)
            {
                var fileName = Path.GetFileName(filePath);
                var fileHash = GetMD5Hash(File.ReadAllBytes(filePath));

                builder.AppendLine($"{fileName} - {fileHash}");
            }

            MessageBox.Show(builder.ToString());

            string GetMD5Hash(byte[] data)
            {
                var hash = MD5.Create().ComputeHash(data);

                return BitConverter.ToString(hash).Replace("-", "").ToLower();
            }
        }
    }
}
