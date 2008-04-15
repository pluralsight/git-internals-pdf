
Object.extend(Hash.prototype, {
  // Emit a hash in the format of CSS property strings,
  // ready for wrapping in an element declaration.
  toCSS: function() {
    var css = '';
    this.each(function(pair) {
      css += "\t" + pair.key.gsub(/_/, '-') + ": " + pair.value + ";\n";
    });
    return css;
  }
});

var BaselineRhythmMetrics = Class.create();
BaselineRhythmMetrics.prototype = {

  // Make a new object for calculations, using the body's font-size and line-height.
  //
  // If you need to use different settings, explicitly set body_font_size_px and body_line_height_px.
  initialize: function() {
    var body = $$('body').first();
    this.body_font_size_px = parseInt(body.getStyle('font-size'));
    this.body_line_height_px = parseInt(body.getStyle('line-height'));
    this.body_line_height_em = this.calculateLineHeight(this.body_font_size_px);

    // Matches HTML tags to font size offsets.
    // Font size offset will be added to the body font size.
    this.element_mappings = $H({
      "h1":8,
      "h2":6,
      "h3":4,
      "h4":2,
      "p, ul, blockquote, pre, td, th, label":0,
      "p.small":-2
    });
  },

  // Returns a hash with font size and line height in
  // px and em for the provided font size, using
  // the body line height.
  calculateForSize: function(font_size_px) {
    return $H({
      'font_size_px':font_size_px,
      'font_size_em':(font_size_px/this.body_font_size_px),
      'line_height_px':this.body_line_height_px,
      'line_height_em':this.calculateLineHeight(font_size_px)
    });
  },

  calculateForSizeAsCSSProperties: function(font_size_px) {
    properties = this.calculateForSize(font_size_px);
    return $H({
      'margin':0,
      'font-size':properties.font_size_em + "em",
      'line-height':properties.line_height_em + "em",
      'margin-bottom':properties.line_height_em + "em"
    })
  },

  // Calculate line height for a single font size,
  // using the body line height.
  calculateLineHeight: function(font_size_px) {
    return (this.body_line_height_px/font_size_px);
  },
  
  // TODO Return the calculated font sizes and line heights as a CSS string.
  toCSS: function() {
    var _metrics = this;
    standard_line_height = this.calculateLineHeight(this.body_font_size_px);
    
    var css = "body {\n";
    css += "\tfont-size: " + this.body_font_size_px + "px;\n";
    css += "\tline-height: " + standard_line_height + "em;\n";
    css += "\tmargin: 0; padding: 0\n";
    css += "}\n";

    //
    this.element_mappings.each(function(pair) {
      tagname = pair.key;
      tag_font_size = _metrics.body_font_size_px + pair.value;
      
      css += tagname + " {\n";
      css += _metrics.calculateForSizeAsCSSProperties(tag_font_size).toCSS();
      css += "}\n";
    });

    css += "table {\n";
    css += "\tborder-collapse: collapse;\n";
    css += "\tmargin-bottom: " + standard_line_height + "em;\n";
    css += "}\n";

    return css;
  },
  
  // TODO Set calculated values on the actual elements in the page.
  applyStyles: function() {
    var _metrics = this;
    
    $$('body').first().setStyle({'font-size':_metrics.body_font_size_px + "px"});
    $$('body').first().setStyle({'line-height':_metrics.body_line_height_em + "em"});

    this.element_mappings.each(function(pair) {
      tagnames = pair.key;
      tag_font_size = _metrics.body_font_size_px + pair.value;
                
      tagnames.split(/, /).each(function(tagname){
        $$(tagname).each(function(element){
          element.setStyle(_metrics.calculateForSizeAsCSSProperties(tag_font_size));
        })
      });
    });
  }
  
}

