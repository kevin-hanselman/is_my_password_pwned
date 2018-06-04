using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;

// https://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x804 上介绍了“空白页”项模板

namespace checkpswd
{
    /// <summary>
    /// 可用于自身或导航至 Frame 内部的空白页。
    /// </summary>
    public sealed partial class MainPage : Page
    {
        public MainPage()
        {
            this.InitializeComponent();
        }

        private void textDescription_Copy_SelectionChanged(object sender, RoutedEventArgs e)
        {

        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            checkbutton.IsEnabled = false;
            passwordBox.IsEnabled = false;
            Bin b = new Bin();
            Bin.Callback c = callback;
            textTips.Text = "";
            b.Test(passwordBox.Password, c);

        }
        void callback(string s, string arg)
        {
            if (s.Equals("[DONE]"))
            {
                checkbutton.IsEnabled = true;
                passwordBox.IsEnabled = true;
            }
            else
            {
                string a = string.Format(s, arg);
                textTips.Text += a;
                textTips.Text += "\r\n";
            }

        }

        private void passwordBox_KeyDown(object sender, Windows.UI.Xaml.Input.KeyRoutedEventArgs e)
        {
            if (e.Key == Windows.System.VirtualKey.Enter)
            {
                Button_Click(sender, e);
            }
        }
    }
}
