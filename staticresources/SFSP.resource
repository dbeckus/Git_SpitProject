// convert hex to base64
var b64map="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
var b64pad="=";

function hex2b64(h) {
  var i;
  var c;
  var ret = "";
  for(i = 0; i+3 <= h.length; i+=3) {
    c = parseInt(h.substring(i,i+3),16);
    ret += b64map.charAt(c >> 6) + b64map.charAt(c & 63);
  }
  if(i+1 == h.length) {
    c = parseInt(h.substring(i,i+1),16);
    ret += b64map.charAt(c << 2);
  }
  else if(i+2 == h.length) {
    c = parseInt(h.substring(i,i+2),16);
    ret += b64map.charAt(c >> 2) + b64map.charAt((c & 3) << 4);
  }
  while((ret.length & 3) > 0) ret += b64pad;
  ret=ret.replace(/(....)/g,"$1-");
  return ret.replace(/-$/,"");
}

// convert a base64 string to hex
function b64tohex(s) {
  s=s.replace(/-/g,"");
  var ret = ""
  var i;
  var k = 0; // b64 state, 0-3
  var slop;
  for(i = 0; i < s.length; ++i) {
    if(s.charAt(i) == b64pad) break;
    v = b64map.indexOf(s.charAt(i));
    if(v < 0) continue;
    if(k == 0) {
      ret += int2char(v >> 2);
      slop = v & 3;
      k = 1;
    }
    else if(k == 1) {
      ret += int2char((slop << 2) | (v >> 4));
      slop = v & 0xf;
      k = 2;
    }
    else if(k == 2) {
      ret += int2char(slop);
      ret += int2char(v >> 2);
      slop = v & 3;
      k = 3;
    }
    else {
      ret += int2char((slop << 2) | (v >> 4));
      ret += int2char(v & 0xf);
      k = 0;
    }
  }
  if(k == 1)
    ret += int2char(slop << 2);
  return ret;
}


var publicExponent="10001";
var privateExponent="00bb2f80ccb62568ccad828f2a8df9394a4fcfa69abf1abe43031ae1cfe6e68d" +
	"0315e0918c21779b5f2cf057c490e45f4ca44fbe8363273f63696e74438a4a9a01";
var modulus="C726268CEDB91D10FB68A59F929140836DD27A863526B032CE8523F38911E72D" +
	"ABEC29ACE0D48D81A28BFC22DD6C94AFEDEDBFB01EC0A94AFBDA8CB63A8731E7";


// encrypt
function SPencrypt(license) {

	var rsa = new RSAKey();
	rsa.setPrivate(modulus,publicExponent,privateExponent);

	var res=rsa.sign(license);
	return hex2b64(res);
}


// encrypt
function SPdecrypt(key) {
	var rsa = new RSAKey();
	rsa.setPublic(modulus,publicExponent);

	var res=rsa.verify(b64tohex(key));
	return (res);
}
