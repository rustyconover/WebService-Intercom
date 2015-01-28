use Moops -strict;

# ABSTRACT: represents a user

=pod

=head1 NAME

WebService::Intercom::User - represent a user.

=head1 SYNOPSIS

  my $user = $intercom->user_create_or_update(
     email => 'test@example.com', 
     name => 'test user');
  
  # Retrieve an existing user.
  my $existing_user = $intercom->user_get(email => 'test2@example.com');

  # Add a tag to a user
  $user->tag('test tag');
  $user->untag('test tag');

  # Change the user's name or any other value
  $user->name = 'new name';
  $user->email = 'new-email@example.com';
  $user->save();

  # Delete the user
  $user->delete();

  # Add a note
  $user->add_note(body => "This is a test note");
 
  # Add an event
  $user->add_event(event_name => 'test event');

=head1 DESCRIPTION

Provides an object that represents a user at Intercom.  

=head2 ATTRIBUTES

Attributes are defined at L<http://doc.intercom.io/api/#users>

=over

=item type

=item id

=item created_at

=item signed_up_at

=item updated_at

=item user_id

=item email

=item name

=item custom_attributes

=item last_request_at

=item session_count

=item avatar

=item unsubscribed_from_emails

=item location_data

=item user_agent_data

=item last_seen_ip

=item companies

=item social_profiles

=item segments

=item tags

=item intercom - the WebService::Intercom object that created this user object

=back

=head2 METHODS

=over

=item save() - save any changes made to this object back to
Intercom.io, returns a new WebService::Intercom::User object with the
updated user.

=item delete() - delete this user at Intercom.io

=item tag(name => $tag_name) - Add a tag to this user

=item tag(WebService::Intercom::Tag) - Add a tag to this user

=item untag(name => $tag_name) - Remove a tag from this user

=item add_note(admin_id => $admin_id, body => $message) - Add a note to this user

=item add_event(event_name => $event_name, created_at => time, metadata => {}) - Add an event to this user.

=back

=cut

class WebService::Intercom::User types WebService::Intercom::Types {
    has 'type' => (is => 'ro');
    has 'id' => (is => 'ro');
    has 'created_at' => (is => 'rw', isa => Int);
    has 'signed_up_at' => (is => 'rw', isa => Int);
    has 'updated_at' => (is => 'rw', isa => Int);
    has 'user_id' => (is => 'rw', isa => Str);
    has 'email' => (is => 'rw', isa => Str);
    has 'name' => (is => 'rw', isa => Str);
    has 'custom_attributes' => (is => 'rw', isa => CustomAttributesType);
    has 'last_request_at' => (is => 'rw', isa => Int);
    has 'session_count' => (is => 'ro', isa => Int);
    has 'avatar' => (is => 'ro', isa => AvatarType);
    has 'unsubscribed_from_emails' => (is => 'rw', isa => Bool);
    has 'location_data' => (is => 'ro', isa => LocationDataType);
    has 'user_agent_data' => (is => 'ro', isa => Str);
    has 'last_seen_ip' => (is => 'ro', isa => IPAddressType);
    has 'companies' => (is => 'ro', isa => CompaniesListType);
    has 'social_profiles' => (is => 'ro', isa => SocialProfileListType);
    has 'segments' => (is => 'ro', isa => SegmentsListType);
    has 'tags' => (is => 'ro', isa => TagsListType);

    has 'intercom' => (is => 'ro', isa => InstanceOf["WebService::Intercom"], required => 1);

    method save() {
        $self->intercom->user_create_or_update($self);
    }

    method delete() {
        $self->intercom->user_delete($self);
    }

    multi method tag(Str :$name) {
        $self->intercom->tag_items(name => $name,
                                   users => [{
                                       id => $self->id,
                                       email => $self->email,
                                       user_id => $self->user_id,
                                   }]);
    }

    multi method tag(WebService::Intercom::Tag $tag) {
        $self->intercom->tag_items(name => $tag->name,
                                   users => [{
                                       id => $self->id,
                                       email => $self->email,
                                       user_id => $self->user_id,
                                   }]);
    }


    
    method untag(Str :$name) {
        $self->intercom->tag_items(name => $name,
                                   users => [{
                                       id => $self->id,
                                       email => $self->email,
                                       user_id => $self->user_id,
                                       untag => 1
                                   }]);
    }

    method add_note(Str :$admin_id?,
                    Str :$body?) {
        $self->intercom->note_create(id => $self->id,
                                     email => $self->email,
                                     user_id => $self->user_id,
                                     admin_id => $admin_id,
                                     body => $body);
    }

    method add_event(EventNameType :$event_name,
                     Maybe[Int] :$created_at?,
                     EventMetadataType :$metadata? where { scalar(keys %$_) <= 5 }) {
        $self->intercom->event_create(user_id => $self->user_id,
                                      email => $self->email,
                                      event_name => $event_name,
                                      created_at => $created_at,
                                      metadata => $metadata);
    }
};
1;
