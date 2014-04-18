part of timetracker;

@Component(
    selector: 'circular-progress-bar[ng-model]',
    template: '<svg></svg>',
    publishAs: 'cmp',
    map: const {
      'radius': '@radius',
      'stroke-color': '@strokeColor',
      'stroke-width': '@strokeWidth'
    }
)
class CircularProgressBarComponent implements ShadowRootAware {
  
  num _radius = 32;
  String _strokeColor = '#428bca';
  num _strokeWidth = 6;
  
  //set width(String value) _width = num.parse(value);
  //set height(String value) => _height = num.parse(value);
  
  svg.SvgSvgElement svgEl;
  svg.PathElement arc = new svg.PathElement();
  dom.Element element;
  Scope scope;
  NgModel ngModel;
  
  CircularProgressBarComponent(dom.Element this.element, Scope this.scope, NgModel this.ngModel) {
  }
  
  set radius (String value) {
    if (value != null) {
      _radius = num.parse(value);
    }
  }

  set strokeWidth (String value) {
    if (value != null) {
      _strokeWidth = num.parse(value);
    }
  }
  
  set strokeColor (String value) {
    if (value != null) {
      _strokeColor = value;
    }
  }
  
  _updateArc(percent) {
    var startAngle = -90;
    var centre = _radius,
        radius = _radius-_strokeWidth/2,
        strokeWidth = _strokeWidth;

    var radians = Math.PI*(startAngle)/180;
    var startX = centre + radius * Math.cos(radians);
    var startY = centre + radius * Math.sin(radians);
    
    var d = Math.min(359, percent*360),
        dr = d+startAngle;
    radians = Math.PI*(dr)/180;
    var endx = centre + radius * Math.cos(radians),
        endy = centre + radius * Math.sin(radians),
        largeArc = d>180 ? 1 : 0;
    var pathData = "M"+startX.toString()+","+startY.toString()+" A"+radius.toString()+","+radius.toString()+" 0 "+largeArc.toString()+",1 "+endx.toString()+","+endy.toString();    
    
    arc.remove();
    arc = new svg.PathElement();
    arc.attributes = {
      'd': pathData,
      'stroke': _strokeColor,
      'fill': 'none',
      'stroke-width': strokeWidth.toString()
    };
    
    svgEl.append(arc);
  }
  
  onShadowRoot(dom.ShadowRoot root) {
    svgEl = element.shadowRoot.querySelector('svg');
    
    // aggiorna il render di ngModel
    ngModel.render = (num percent) {
      _updateArc(percent);
    };
    
    _updateArc(ngModel.modelValue);
  }
}
