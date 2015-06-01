Asset files from stackview source are included in rails_stackview under 
`./vendor/assets` subdirs. 

To refresh with recent source, do a git checkout of stackview somewhere, then
from rails_stackview root dir, run:

    RUBYLIB=./source_tools/ rails generate copy_stackview_assets path_to_stackview_source -f

The git SHA of stackview source that was copied into rails_stackview will be
saved at ./vendor/assets/stackview.sha

Part of the routine for copying stackview assets will also replace all
CSS `url()` in stackview CSS source with rails-sass `asset-url` calls, to
play well with the asset pipeline.  To support this, the stackview
CSS will be copied as a `.sass` file, even though we are copying generated
stackview CSS, and it's not otherwise sass. 