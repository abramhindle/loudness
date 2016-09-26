/**
 * Loudness 0.666 shell
 * was AnderShell - Just a small CSS demo
 *
 * Copyright (c) 2016, Abram Hindle 
 * Copyright (c) 2011-2013, Anders Evenrud <andersevenrud@gmail.com>
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met: 
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer. 
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution. 
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * (setq js-indent-level 2)
 */
(function() {

  var $output;
  var _inited = false;
  var _locked = false;
  var _sending_keys = false;
  var sc = "127.0.0.1:57120";
  var _buffer = [];
  var _obuffer = [];
  var _ibuffer = [];
  var _cwd = "L0666";
  var _prompt = function() { return _cwd + " $ "; };
  var _history = [];
  var _hindex = -1;
  var _lhindex = -1;
  var keyplay = "/playrandom";
  function sendSimpleOSC(command) {
    sendAJAX("POST","http://"+window.location.host+"/osc",
             {"queue":[["127.0.0.1:10000",command]]},false);        
  }
  function sendSimpleOSCHost(host,command) {
    sendAJAX("POST","http://"+window.location.host+"/osc",
             {"queue":[[host,command]]},false);        
  }
  function sendSingleOSC(host,command,typea,arg1) {
    sendAJAX("POST","http://"+window.location.host+"/osc",
             {"queue":[[host,command,typea,arg1]]},false);        
  }
  function sendDoubleOSC(host,command,typea,arg1,typeb,arg2) {
    sendAJAX("POST","http://"+window.location.host+"/osc",
             {"queue":[[host,command,typea,arg1,typeb,arg2]]},false);        
  }
  function say(str) {
    sendSingleOSC("127.0.0.1:5005","/say","s",str);
  }
  function sendKeyStroke(k,kc) {
    sendDoubleOSC("127.0.0.1:10000",keyplay,"i",k,"i",Math.floor(200*Math.random()));
  }
  
  var _commands = {
    
    clear: function() {
      return false;
    },
    
    delay: function() {
      sendSimpleOSC("/delaytest");  
      return "Call delaytest";
    },
    random: function() {
        sendSimpleOSC("/randomsearch");  
        return "Call random search";
    },
    genetic: function() {
      sendSimpleOSC("/genetic");  
      return "Call genetic search";
    },
    twiddle: function() {
      sendSimpleOSC("/twiddle");  
      return "Call twiddle";
    },
    rms: function() {
      sendSimpleOSC("/rms");  
      return "Measure RMS";
    },
    micon: function() {
      sendSingleOSC("127.0.0.1:57120","/amp","f",1.0);  
      return "Turn on Mic";
    },
    micoff: function() {
      sendSingleOSC("127.0.0.1:57120","/amp","f",0.0);  
      return "Turn off Mic";
    },
    init: function() {
      //say("Welcome to Loudness Version 0.666.");
      //say("This program is licensed under the GNU Public License Version 3.0.");
      //say("Warning: this program may damage Public Address systems.");
      
      sendSimpleOSCHost(sc,"/intro");  
      return "Initializing";
    },
    warning: function() {
      say("Warning: this program may damage Public Address systems.");
      return "";
    },
    version: function() {
      //say("Warning: this program may damage Public Address systems.");
      say("Loudness Version 0.666.");
      return "";
    },
    
    end: function() {
      //say("Welcome to Loudness Version 0.666.");
      //say("This program is licensed under the GNU Public License Version 3.0.");
      //say("Warning: this program may damage Public Address systems.");
      
      sendSimpleOSCHost(sc,"/end");  
      return "Ending";
    },
    say: function() {
      var speech = Array.prototype.slice.call(arguments, 0);
      say(speech.join(" "));
      return "Speaking";
    },
    nr: function() {
      _sending_keys = false;
    },
    sr: function() {
      _sending_keys = true;
      keyplay = "/playrandom";
      return "Playing Random";
    },
    sg: function() {
      _sending_keys = true;
      keyplay = "/playgenetic";
      return "Playing Genetic";
    },
    st: function() {
      _sending_keys = true;
      keyplay = "/playtwiddle";
      return "Playing Twiddle";
    },
    t3: function() {
      _sending_keys = true;
      keyplay = "/play3";
      return "Playing 3";
    },
    
    help: function() {
      var out = [
        'help               This command',
        'clear              Clears the screen',
        'delay              delaytest',
        'init               init',
        'end                end',
        'say                say it',
        'nr                 stop recording',
        'sr                 stop recording',
        ''
      ];
      return out.join("\n");
    }

  };

  /////////////////////////////////////////////////////////////////
  // UTILS
  /////////////////////////////////////////////////////////////////

  function setSelectionRange(input, selectionStart, selectionEnd) {
    if (input.setSelectionRange) {
      input.focus();
      input.setSelectionRange(selectionStart, selectionEnd);
    }
    else if (input.createTextRange) {
      var range = input.createTextRange();
      range.collapse(true);
      range.moveEnd('character', selectionEnd);
      range.moveStart('character', selectionStart);
      range.select();
    }
  }

  function format(format) {
    var args = Array.prototype.slice.call(arguments, 1);
    var sprintfRegex = /\{(\d+)\}/g;

    var sprintf = function (match, number) {
      return number in args ? args[number] : match;
    };

    return format.replace(sprintfRegex, sprintf);
  }


  function padRight(str, l, c) {
    return str+Array(l-str.length+1).join(c||" ")
  }

  function padCenter(str, width, padding) {
    var _repeat = function(s, num) {
      for( var i = 0, buf = ""; i < num; i++ ) buf += s;
      return buf;
    };

    padding = (padding || ' ').substr( 0, 1 );
    if ( str.length < width ) {
      var len     = width - str.length;
      var remain  = ( len % 2 == 0 ) ? "" : padding;
      var pads    = _repeat(padding, parseInt(len / 2));
      return pads + str + pads + remain;
    }

    return str;
  }
  
  function sendAJAX(method,uri,msg,cb) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
      if (xhr.readyState==4) {
        try {
          if (xhr.status==200) {
            var text = xhr.responseText;
            if (cb) {
              cb(text);
            }
          }
        } 
        catch(e) {
          alert('Error: ' + e.name);
        }
      }
    };
    xhr.open(method,uri);
    xhr.overrideMimeType("application/json");
    xhr.setRequestHeader('Accept', 'application/json');
    xhr.send( JSON.stringify( msg ) );
    return xhr;
  }
    

  window.requestAnimFrame = (function(){
    return  window.requestAnimationFrame       ||
    window.webkitRequestAnimationFrame ||
    window.mozRequestAnimationFrame    ||
    function( callback ){
      window.setTimeout(callback, 1000 / 60);
    };
  })();

  /////////////////////////////////////////////////////////////////
  // SHELL
  /////////////////////////////////////////////////////////////////

  (function animloop(){
    requestAnimFrame(animloop);

    if ( _obuffer.length ) {
      $output.value += _obuffer.shift();
      _locked = true;

      update();
    } else {
      if ( _ibuffer.length ) {
        $output.value += _ibuffer.shift();

        update();
      }

      _locked = false;
      _inited = true;
    }
  })();

  function print(input, lp) {
    update();
    _obuffer = _obuffer.concat(lp ? [input] : input.split(''));
  }

  function update() {
    $output.focus();
    var l = $output.value.length;
    setSelectionRange($output, l, l);
    $output.scrollTop = $output.scrollHeight;
  }

  function clear() {
    $output.value = '';
    _ibuffer = [];
    _obuffer = [];
    print("");
  }

  function command(cmd) {
    print("\n");
    if ( cmd.length ) {
      var a = cmd.split(' ');
      var c = a.shift();
      if ( c in _commands ) {
        var result = _commands[c].apply(_commands, a);
        if ( result === false ) {
          clear();
        } else {
          print(result || "\n", true);
        }
      } else {
        print("Unknown command: " + c, true);
      }

      _history.push(cmd);
    }
    print("\n\n" + _prompt());

    _hindex = -1;
  }

  function nextHistory() {
    if ( !_history.length ) return;

    var insert;
    if ( _hindex == -1 ) {
      _hindex  = _history.length - 1;
      _lhindex = -1;
      insert   = _history[_hindex];
    } else {
      if ( _hindex > 1 ) {
        _lhindex = _hindex;
        _hindex--;
        insert = _history[_hindex];
      }
    }

    if ( insert ) {
      if ( _lhindex != -1 ) {
        var txt = _history[_lhindex];
        $output.value = $output.value.substr(0, $output.value.length - txt.length);
        update();
      }
      _buffer = insert.split('');
      _ibuffer = insert.split('');
    }
  }

  window.onload = function() {
    $output = document.getElementById("output");
    $output.contentEditable = true;
    $output.spellcheck = false;
    $output.value = '';

    $output.onkeydown = function(ev) {
      var k = ev.which || ev.keyCode;
      var cancel = false;

      if ( !_inited ) {
        cancel = true;
      } else {
        if ( k == 9 ) {
          cancel = true;
        } else if ( k == 38 ) {
          nextHistory();
          cancel = true;
        } else if ( k == 40 ) {
          cancel = true;
        } else if ( k == 37 || k == 39 ) {
          cancel = true;
        }
      }

      if ( cancel ) {
        ev.preventDefault();
        ev.stopPropagation();
        return false;
      }

      if ( k == 8 ) {
        if ( _buffer.length ) {
          _buffer.pop();
        } else {
          ev.preventDefault();
          return false;
        }
      }

      return true;
    };

    $output.onkeypress = function(ev) {
      ev.preventDefault();
      if ( !_inited ) {
        return false;
      }

      var k = ev.which || ev.keyCode;
      if ( k == 13 ) {
        var cmd = _buffer.join('').replace(/\s+/, ' ');
        _buffer = [];
        command(cmd);
      } else {
        if ( !_locked ) {
          var kc = String.fromCharCode(k);
          _buffer.push(kc);
          _ibuffer.push(kc);
          if (  _sending_keys ) {
            // (setq tab-width 4)
            sendKeyStroke(k,kc);
          }
        }
      }

      return true;
    };

    $output.onfocus = function() {
      update();
    };

    $output.onblur = function() {
      update();
    };

    window.onfocus = function() {
      update();
    };
    
    print("Initializing Loudness v 0.666 ....................................................\n");
    print("Copyright (c) 2016,2014 Abram Hindle, Anders Evenrud <andersevenrud@gmail.com>\n\n", true);

    //print("------------------------------------------------------------------------------------------------------------------");
    print(' ""#                      #                             \n', true);
    print('   #     mmm   m   m   mmm#  m mm    mmm    mmm    mmm  \n', true);
    print('   #    #" "#  #   #  #" "#  #"  #  #"  #  #   "  #   " \n', true);
    print('   #    #   #  #   #  #   #  #   #  #""""   """m   """m \n', true);
    print('   "mm  "#m#"  "mm"#  "#m##  #   #  "#mm"  "mmm"  "mmm" \n', true);
    print('                                                        \n', true);
    print('            mmmm           mmm    mmm    mmm \n', true);
    print('           m"  "m        m"   " m"   " m"   "\n', true);
    print('           #  m #        #m""#m #m""#m #m""#m\n', true);
    print('           #    #        #    # #    # #    #\n', true);
    print('            #mm#    #     #mm#"  #mm#"  #mm#"\n', true);
    print('                                   \n', true);
    print('\n', true);
    //print(padCenter("All graphics are created using CSS, no static files or images\n", 113), true);
    print("Type 'help' for a list of available commands.\n", true);
    print("\n\n" + _prompt());
    setInterval(function() {
      sendAJAX("GET","http://"+window.location.host+"/msg","", function(text) {
        var l = JSON.parse(text);
        for (var i = 0; i < l.length; i++) {
          print("\n"+l[i].join("\n")+"\n");
        }
      });
    }, 2000);
  };
})();
