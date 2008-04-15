/*
  Copyright 2007 Topfunky Corporation
                 http://topfunky.com
*/

var dynamic_id_counter = 0;

Event.addBehavior({
  
  '.redeem_button:click': function() {
    return confirm('Do you want to spend 1 credit on this product?');
  },
  
  'select#order_country_id:change': function() {
    Peep.toggleZipcode(this, 'order_zipcode_label');
  },
  
  'select#user_country_id:change': function() {
    Peep.toggleZipcode(this, 'user_zipcode_p');
  },
  
  "#typography:click": function(event) {
    showBaselines(); return false;
  },
  
  "a#rails-machine": function(event) {
    setSponsorImage(this, '/images/sponsors/rails-machine.png');
  },
  
  "a#samson": function(event) {
    setSponsorImage(this, '/images/sponsors/samson.jpg');
  },
  
  'img.article': function(event) { 
    fitImageToBaseline(this);
  },
  
  'div.flash_tmp': function(event) {
    setTimeout(function() {
      this.hide();
    }.bind(this), 3000);
  },
  
  '.bugs form#new_bug textarea#bug_how_to_fix': function(event) {
    this.hide();
    var show_link = "<a onclick=\"return Peep.showBugForm();\" id=\"yeslink\">YES</a>";
    new Insertion.Before(this, show_link);
  },
  
  'input.error': function() {
    $(this).focus();
  },
  
  '#paypal_form': function() {
    $(this).submit();
  },
  
  'form#login input#email': function() {
    Field.focus(this);
  }  

/*
  // TODO Show buttons instead of submit input elements.
  "input.submit": function(event) { "replaceWithButton(this)" }
*/    

});


var Peep = {
  toggleZipcode: function(form, element) {
    /* Show zipcode input if USA is selected. */
    if ($F(form) == 229) {
      $(element).show();
    } else {
      $(element).hide();
    }    
  },
  
  showBugForm: function() {
    $('bug_how_to_fix').show();
    $('bug_how_to_fix').focus();
    $('yeslink').hide();
    return false;
  }
}

/*
  Replace column backgrounds with a lined 18px baseline image.
  
  For debugging and amusement.
*/
function showBaselines() {
  if ($('body').getStyle('font-size') != '12px') {
    alert("You are using a non-standard font size, so the lines may not align correctly.");
  }
  /* Show baseline image on columns */  
  $$('.column').each(function(item) {
      item.setStyle({'background':'url(/images/debug/baseline-18.png)'});
  });
  /* Make footer text black so it can be seen */  
  $('footer').setStyle({'color':'black'});
  $$('#footer a').each(function(item) {
    item.setStyle({'color':'black'});
  });
}

function setSponsorImage(sponsor_id, image_src) {
  $(sponsor_id).addClassName('sponsor_image');
  $(sponsor_id).setStyle({
    'background':'black url(' + image_src + ') no-repeat center'
  });
  $(sponsor_id).innerHTML = '';
}

/*
  Add a Javascript powered form-submitting button and remove the submit element it represents.
*/
function replaceWithButton(item) {
  new Insertion.After(item, "<button onclick=\"this.form.submit(); return false;\">" + item.value + "</button>");
  $(item).remove(); /* Get rid of original submit button. */
}

/*
  Replace an image with a div that uses the image as a background.
  
  Set the height of the image to an appropriate multiple of the line-height.
*/
function fitImageToBaseline(item) {  
  id = generateDynamicId();
  var baseline_rhythm_metrics = new BaselineRhythmMetrics();
  
  // Calculate height of image in ems  
  height = (item.getHeight() / parseInt(baseline_rhythm_metrics.body_font_size_px)); 
  // Round down to next smallest multiple of the line height
  height -= (height % baseline_rhythm_metrics.body_line_height_em);
  
  new Insertion.After(item, "<div id=\"" + id + "\"></div>");
  $(id).setStyle({
    'display':'block',
    'height': height + 'em',
    'background':'transparent url(' + item.src + ') no-repeat center'
  })

  $(item).remove(); /* Get rid of original image. */  
}

/* Returns a string that can be used as a unique id for dynamically generated elements. */
function generateDynamicId() {
  dynamic_id_counter++;
  return "dynamic_" + dynamic_id_counter;
}

