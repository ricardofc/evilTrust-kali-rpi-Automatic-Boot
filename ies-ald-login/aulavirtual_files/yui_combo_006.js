/*
YUI 3.17.2 (build 9c3c78e)
Copyright 2014 Yahoo! Inc. All rights reserved.
Licensed under the BSD License.
http://yuilibrary.com/license/
*/

YUI.add("event-mousewheel",function(e,t){var n="DOMMouseScroll",r=function(t){var r=e.Array(t,0,!0),i;return e.UA.gecko?(r[0]=n,i=e.config.win):i=e.config.doc,r.length<3?r[2]=i:r.splice(2,0,i),r};e.Env.evt.plugins.mousewheel={on:function(){return e.Event._attach(r(arguments))},detach:function(){return e.Event.detach.apply(e.Event,r(arguments))}}},"3.17.2",{requires:["node-base"]});
/*
YUI 3.17.2 (build 9c3c78e)
Copyright 2014 Yahoo! Inc. All rights reserved.
Licensed under the BSD License.
http://yuilibrary.com/license/
*/

YUI.add("event-resize",function(e,t){e.Event.define("windowresize",{on:e.UA.gecko&&e.UA.gecko<1.91?function(t,n,r){n._handle=e.Event.attach("resize",function(e){r.fire(e)})}:function(t,n,r){var i=e.config.windowResizeDelay||100;n._handle=e.Event.attach("resize",function(t){n._timer&&n._timer.cancel(),n._timer=e.later(i,e,function(){r.fire(t)})})},detach:function(e,t){t._timer&&t._timer.cancel(),t._handle.detach()}})},"3.17.2",{requires:["node-base","event-synthetic"]});
/*
YUI 3.17.2 (build 9c3c78e)
Copyright 2014 Yahoo! Inc. All rights reserved.
Licensed under the BSD License.
http://yuilibrary.com/license/
*/

YUI.add("event-hover",function(e,t){var n=e.Lang.isFunction,r=function(){},i={processArgs:function(e){var t=n(e[2])?2:3;return n(e[t])?e.splice(t,1)[0]:r},on:function(e,t,n,r){var i=t.args?t.args.slice():[];i.unshift(null),t._detach=e[r?"delegate":"on"]({mouseenter:function(e){e.phase="over",n.fire(e)},mouseleave:function(e){var n=t.context||this;i[0]=e,e.type="hover",e.phase="out",t._extra.apply(n,i)}},r)},detach:function(e,t,n){t._detach.detach()}};i.delegate=i.on,i.detachDelegate=i.detach,e.Event.define("hover",i)},"3.17.2",{requires:["event-mouseenter"]});
/*
YUI 3.17.2 (build 9c3c78e)
Copyright 2014 Yahoo! Inc. All rights reserved.
Licensed under the BSD License.
http://yuilibrary.com/license/
*/

YUI.add("event-valuechange",function(e,t){var n="_valuechange",r="value",i="nodeName",s,o={POLL_INTERVAL:50,TIMEOUT:1e4,_poll:function(t,r){var i=t._node,s=r.e,u=t._data&&t._data[n],a=0,f,l,c,h,p,d;if(!i||!u){o._stopPolling(t);return}l=u.prevVal,h=u.nodeName,u.isEditable?c=i.innerHTML:h==="input"||h==="textarea"?c=i.value:h==="select"&&(p=i.options[i.selectedIndex],c=p.value||p.text),c!==l&&(u.prevVal=c,f={_event:s,currentTarget:s&&s.currentTarget||t,newVal:c,prevVal:l,target:s&&s.target||t},e.Object.some(u.notifiers,function(e){var t=e.handle.evt,n;a!==1?e.fire(f):t.el===d&&e.fire(f),n=t&&t._facade?t._facade.stopped:0,n>a&&(a=n,a===1&&(d=t.el));if(a===2)return!0}),o._refreshTimeout(t))},_refreshTimeout:function(e,t){if(!e._node)return;var r=e.getData(n);o._stopTimeout(e),r.timeout=setTimeout(function(){o._stopPolling(e,t)},o.TIMEOUT)},_startPolling:function(t,s,u){var a,f;if(!t.test("input,textarea,select")&&!(f=o._isEditable(t)))return;a=t.getData(n),a||(a={nodeName:t.get(i).toLowerCase(),isEditable:f,prevVal:f?t.getDOMNode().innerHTML:t.get(r)},t.setData(n,a)),a.notifiers||(a.notifiers={});if(a.interval){if(!u.force){a.notifiers[e.stamp(s)]=s;return}o._stopPolling(t,s)}a.notifiers[e.stamp(s)]=s,a.interval=setInterval(function(){o._poll(t,u)},o.POLL_INTERVAL),o._refreshTimeout(t,s)},_stopPolling:function(t,r){if(!t._node)return;var i=t.getData(n)||{};clearInterval(i.interval),delete i.interval,o._stopTimeout(t),r?i.notifiers&&delete i.notifiers[e.stamp(r)]:i.notifiers={}},_stopTimeout:function(e){var t=e.getData(n)||{};clearTimeout(t.timeout),delete t.timeout},_isEditable:function(e){var t=e._node;return t.contentEditable==="true"||t.contentEditable===""},_onBlur:function(e,t){o._stopPolling(e.currentTarget,t)},_onFocus:function(e,t){var s=e.currentTarget,u=s.getData(n);u||(u={isEditable:o._isEditable(s),nodeName:s.get(i).toLowerCase()},s.setData(n,u)),u.prevVal=u.isEditable?s.getDOMNode().innerHTML:s.get(r),o._startPolling(s,t,{e:e})},_onKeyDown:function(e,t){o._startPolling(e.currentTarget,t,{e:e})},_onKeyUp:function(e,t){(e.charCode===229||e.charCode===197)&&o._startPolling(e.currentTarget,t,{e:e,force:!0})},_onMouseDown:function(e,t){o._startPolling(e.currentTarget,t,{e:e})},_onSubscribe:function(t,s,u,a){var f,l,c,h,p;l={blur:o._onBlur,focus:o._onFocus,keydown:o._onKeyDown,keyup:o._onKeyUp,mousedown:o._onMouseDown},f=u._valuechange={};if(a)f.delegated=!0,f.getNodes=function(){return h=t.all("input,textarea,select").filter(a),p=t.all('[contenteditable="true"],[contenteditable=""]').filter(a),h.concat(p)},f.getNodes().each(function(e){e.getData(n)||e.setData(n,{nodeName:e.get(i).toLowerCase(),isEditable:o._isEditable(e),prevVal:c?e.getDOMNode().innerHTML:e.get(r)})}),u._handles=e.delegate(l,t,a,null,u);else{c=o._isEditable(t);if(!t.test("input,textarea,select")&&!c)return;t.getData(n)||t.setData(n,{nodeName:t.get(i).toLowerCase(),isEditable:c,prevVal:c?t.getDOMNode().innerHTML:t.get(r)}),u._handles=t.on(l,null,null,u)}},_onUnsubscribe:function(e,t,n){var r=n._valuechange;n._handles&&n._handles.detach(),r.delegated?r.getNodes().each(function(e){o._stopPolling(e,n)}):o._stopPolling(e,n)}};s={detach:o._onUnsubscribe,on:o._onSubscribe,delegate:o._onSubscribe,detachDelegate:o._onUnsubscribe,publishConfig:{emitFacade:!0}},e.Event.define("valuechange",s),e.Event.define("valueChange",s),e.ValueChange=o},"3.17.2",{requires:["event-focus","event-synthetic"]});
/*
YUI 3.17.2 (build 9c3c78e)
Copyright 2014 Yahoo! Inc. All rights reserved.
Licensed under the BSD License.
http://yuilibrary.com/license/
*/

YUI.add("event-tap",function(e,t){function a(t,n){n=n||e.Object.values(u),e.Array.each(n,function(e){var n=t[e];n&&(n.detach(),t[e]=null)})}var n=e.config.doc,r=e.Event._GESTURE_MAP,i=r.start,s="tap",o=/pointer/i,u={START:"Y_TAP_ON_START_HANDLE",END:"Y_TAP_ON_END_HANDLE",CANCEL:"Y_TAP_ON_CANCEL_HANDLE"};e.Event.define(s,{publishConfig:{preventedFn:function(e){var t=e.target.once("click",function(e){e.preventDefault()});setTimeout(function(){t.detach()},100)}},processArgs:function(e,t){if(!t){var n=e[3];return e.splice(3,1),n}},on:function(e,t,n){t[u.START]=e.on(i,this._start,this,e,t,n)},detach:function(e,t,n){a(t)},delegate:function(t,n,r,s){n[u.START]=e.delegate(i,function(e){this._start(e,t,n,r,!0)},t,s,this)},detachDelegate:function(e,t,n){a(t)},_start:function(e,t,n,i,s){var a={canceled:!1,eventType:e.type},f=n.preventMouse||!1;if(e.button&&e.button===3)return;if(e.touches&&e.touches.length!==1)return;a.node=s?e.currentTarget:t,e.touches?a.startXY=[e.touches[0].pageX,e.touches[0].pageY]:a.startXY=[e.pageX,e.pageY],e.touches?(n[u.END]=t.once("touchend",this._end,this,t,n,i,s,a),n[u.CANCEL]=t.once("touchcancel",this.detach,this,t,n,i,s,a),n.preventMouse=!0):a.eventType.indexOf("mouse")!==-1&&!f?(n[u.END]=t.once("mouseup",this._end,this,t,n,i,s,a),n[u.CANCEL]=t.once("mousecancel",this.detach,this,t,n,i,s,a)):a.eventType.indexOf("mouse")!==-1&&f?n.preventMouse=!1:o.test(a.eventType)&&(n[u.END]=t.once(r.end,this._end,this,t,n,i,s,a),n[u.CANCEL]=t.once(r.cancel,this.detach,this,t,n,i,s,a))},_end:function(e,t,n,r,i,o){var f=o.startXY,l,c,h=15;n._extra&&n._extra.sensitivity>=0&&(h=n._extra.sensitivity),e.changedTouches?(l=[e.changedTouches[0].pageX,e.changedTouches[0].pageY],c=[e.changedTouches[0].clientX,e.changedTouches[0].clientY]):(l=[e.pageX,e.pageY],c=[e.clientX,e.clientY]),Math.abs(l[0]-f[0])<=h&&Math.abs(l[1]-f[1])<=h&&(e.type=s,e.pageX=l[0],e.pageY=l[1],e.clientX=c[0],e.clientY=c[1],e.currentTarget=o.node,r.fire(e)),a(n,[u.END,u.CANCEL])}})},"3.17.2",{requires:["node-base","event-base","event-touch","event-synthetic"]});
