--
--Build Rider - Rabbit Tank Sparkling
--scripted by Zedja
local s,id=GetID()
local SET_BUILD_RIDER=0x1e04
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:AddMustBeLinkSummoned()
	--Link Summon procedure: 1+ "Build Rider" monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_BUILD_RIDER),1)
	--You can only Link Summon "Build Rider - Rabbit Tank Sparkling" once per turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--This card is also FIRE-Attribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(ATTRIBUTE_FIRE)
	c:RegisterEffect(e1)
	--Cannot be targeted by card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Once per turn, during the Battle Phase (Quick Effect): You can have this card gain ATK equal to half the combined original ATK of all monsters your opponent controls until the end of the Battle Phase, also it can attack all monsters your opponent controls once each this turn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(TIMING_BATTLE_START|TIMING_BATTLE_PHASE)
	e3:SetCountLimit(1)
	e3:SetCondition(function() return Duel.IsBattlePhase() and not Duel.IsDamageStep() end)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	--If you control another face-up "Build Rider" monster, your opponent cannot activate cards or effects during the Battle Phase
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	e4:SetCondition(s.actcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
s.listed_series={SET_BUILD_RIDER}
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	--You cannot Link Summon "Build Rider - Rabbit Tank Sparkling" for the rest of this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype) return c:IsCode(id) and sumtype&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	local atk=0
	for tc in Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):Iter() do
		atk=atk+math.max(tc:GetBaseAttack(),0)
	end
	atk=math.floor(atk/2)
	if atk>0 then
		--Gains ATK until the end of the Battle Phase
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
	--Also it can attack all monsters your opponent controls once each this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	c:RegisterEffect(e2)
end
function s.actcon(e)
	return Duel.IsBattlePhase()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_BUILD_RIDER),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
