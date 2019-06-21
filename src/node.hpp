#pragma once

#include <string>
#include <map>
#include <memory>
#include <cpptoml/cpptoml.hpp>

#include "interface.hpp"
#include "routingtable.hpp"
class Node;
#include "link.hpp"

class Node
{
protected:
    std::string name;

    // interfaces indexed by name and ip address
    std::map<std::string, std::shared_ptr<Interface> > intfs;
    std::map<IPv4Address, std::shared_ptr<Interface> > intfs_ipv4;

    RoutingTable rib;   // global RIB for this node

    // active connected peers indexed by interface name
    std::map<std::string,
        std::pair<std::weak_ptr<Node>, std::weak_ptr<Interface> >
        > active_peers;

    // active links indexed by interface name
    std::map<std::string, std::weak_ptr<Link> > active_links;

public:
    Node(const std::shared_ptr<cpptoml::table>&);

    virtual std::string to_string() const;
    virtual std::string get_name() const;
    virtual bool has_ip(const IPv4Address& addr) const;
    virtual bool has_ip(const std::string& addr) const;

    virtual const std::shared_ptr<Interface>&
    get_interface(const std::string&) const;
    virtual const std::shared_ptr<Interface>&
    get_interface(const IPv4Address&) const;
    virtual const RoutingTable& get_rib() const;
    virtual std::pair<std::shared_ptr<Node>, std::shared_ptr<Interface> >
    get_peer(const std::string& intf_name) const;
    virtual std::shared_ptr<Link>
    get_link(const std::string& intf_name) const;

    virtual void
    add_peer(const std::string&, const std::shared_ptr<Node>&,
             const std::shared_ptr<Interface>&);
    virtual void
    add_link(const std::string&, const std::shared_ptr<Link>&);
};
